import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/config/router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/anon_chat_service.dart';
import '../../domain/anon_chat_model.dart';
import '../../domain/counseling_models.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/leave_chat_dialog.dart';
import '../widgets/report_chat_dialog.dart';

class ChatAnonRoomView extends ConsumerStatefulWidget {
  final String sessionId;
  final String mode;

  const ChatAnonRoomView({
    super.key,
    this.sessionId = '',
    this.mode = 'Cuma mau didengar',
  });

  @override
  ConsumerState<ChatAnonRoomView> createState() => _ChatAnonRoomViewState();
}

class _ChatAnonRoomViewState extends ConsumerState<ChatAnonRoomView> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;
  bool _isBotSession = false;
  bool _isSessionEnded = false;
  StreamSubscription? _sessionSubscription;

  // Presence & Reconnection Tracking
  String _partnerPresenceState = 'online'; // 'online', 'in_background', 'disconnected'
  Timer? _graceTimer;
  int _graceSecondsRemaining = 90;
  final DateTime _roomEnteredAt = DateTime.now();

  // Realtime Status Channel & Indicators
  RealtimeChannel? _statusChannel;
  String _peerStatus = 'idle'; // 'idle', 'typing', 'choosing_emoji'
  Timer? _peerTypingTimer;
  Timer? _debounceTypingTimer;
  int _lastMessageCount = 0;

  final List<Map<String, dynamic>> _fallbackMessages = [
    {
      'id': '1',
      'text': 'Halo! Kamu sudah terhubung secara anonim. Cerita apa saja dengan bebas dan nyaman di sini ya ✨',
      'isMe': false,
      'time': 'Sekarang',
    },
  ];

  Stream<List<AnonMessageModel>>? _messagesStream;
  List<AnonMessageModel> _cachedAnonMessages = [];
  final List<AnonMessageModel> _optimisticMessages = [];
  bool _isStreamConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isAutoRetrying = false;
  final Set<String> _selectedMessageIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStream();
    _checkBotSession();
    _initSessionStream();
    _initStatusChannel();
    _initConnectivityListener();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() {
          _showEmoji = false;
        });
      }
    });
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _autoRetryFailedMessages();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatAnonRoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _initStream();
      _checkBotSession();
      _initSessionStream();
      _initStatusChannel();
    }
  }

  void _initStream() {
    final isRealSession = widget.sessionId.isNotEmpty && widget.sessionId != 'local-session';
    if (isRealSession) {
      _messagesStream = ref.read(anonChatServiceProvider).streamMessages(widget.sessionId);
    } else {
      _messagesStream = null;
    }
  }

  void _checkBotSession() async {
    if (widget.sessionId.isEmpty || widget.sessionId == 'local-session') {
      _isBotSession = true;
      return;
    }
    try {
      final res = await SupabaseService.client
          .from('anon_chat_sessions')
          .select('is_bot_session, status')
          .eq('id', widget.sessionId)
          .maybeSingle();
      if (mounted && res != null) {
        setState(() {
          _isBotSession = res['is_bot_session'] as bool? ?? false;
          final status = res['status'] as String? ?? 'active';
          if (status == 'ended' || status == 'cancelled') {
            _isSessionEnded = true;
          }
        });
      }
    } catch (_) {}
  }

  void _initSessionStream() {
    if (widget.sessionId.isNotEmpty && widget.sessionId != 'local-session') {
      _sessionSubscription?.cancel();
      _sessionSubscription = ref.read(anonChatServiceProvider).streamSession(widget.sessionId).listen((session) {
        if (mounted && session != null) {
          setState(() {
            _isBotSession = session.isBotSession;
            if (session.isEnded) {
              _isSessionEnded = true;
            }
          });
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final myId = SupabaseService.currentUserId;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_statusChannel != null && myId != null) {
        _statusChannel?.sendBroadcastMessage(
          event: 'peer_lifecycle',
          payload: {
            'user_id': myId,
            'state': 'in_background',
          },
        );
      }
      _updatePresence('in_background');
    } else if (state == AppLifecycleState.resumed) {
      if (_statusChannel != null && myId != null) {
        _statusChannel?.sendBroadcastMessage(
          event: 'peer_lifecycle',
          payload: {
            'user_id': myId,
            'state': 'online',
          },
        );
      }
      _updatePresence('online');
      _autoRetryFailedMessages();
    }
  }

  void _updatePresence(String presenceState) {
    final myId = SupabaseService.currentUserId;
    if (_statusChannel != null && myId != null) {
      ref.read(anonChatServiceProvider).trackPresence(
        channel: _statusChannel!,
        userId: myId,
        presenceState: presenceState,
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    ref.invalidate(activeAnonSessionProvider);
    WidgetsBinding.instance.removeObserver(this);
    _graceTimer?.cancel();
    _sessionSubscription?.cancel();
    _broadcastStatus('idle');
    _peerTypingTimer?.cancel();
    _debounceTypingTimer?.cancel();
    if (_statusChannel != null) {
      try {
        SupabaseService.client.removeChannel(_statusChannel!);
      } catch (_) {}
      _statusChannel = null;
    }
    _focusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initStatusChannel() {
    if (_statusChannel != null) {
      try {
        SupabaseService.client.removeChannel(_statusChannel!);
      } catch (_) {}
      _statusChannel = null;
    }

    if (widget.sessionId.isNotEmpty && widget.sessionId != 'local-session') {
      _statusChannel = ref.read(anonChatServiceProvider).createChatStatusChannel(widget.sessionId);
      
      _statusChannel?.onBroadcast(event: 'peer_lifecycle', callback: (payload) {
        final senderId = payload['user_id'] as String?;
        final state = payload['state'] as String?;
        final myId = SupabaseService.currentUserId;

        if (senderId != myId && state != null && mounted) {
          setState(() {
            _partnerPresenceState = state;
          });
          if (state == 'in_background' || state == 'online') {
            _stopGracePeriodTimer();
          } else if (state == 'disconnected') {
            _startGracePeriodTimer();
          }
        }
      });

      _statusChannel?.onBroadcast(event: 'user_status', callback: (payload) {
        final senderId = payload['sender_id'] as String?;
        final status = payload['status'] as String?;
        final myId = SupabaseService.currentUserId;

        if (senderId != myId && status != null && mounted) {
          _stopGracePeriodTimer();
          if (_partnerPresenceState != 'online') {
            setState(() {
              _partnerPresenceState = 'online';
            });
          }
          _peerTypingTimer?.cancel();
          setState(() {
            _peerStatus = status;
          });

          if (status != 'idle') {
            _peerTypingTimer = Timer(const Duration(milliseconds: 3500), () {
              if (mounted) {
                setState(() {
                  _peerStatus = 'idle';
                });
              }
            });
          }
        }
      });

      _statusChannel?.onPresenceSync((_) {
        _handlePresenceSync();
      });

      _statusChannel?.subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _updatePresence('online');
          final myId = SupabaseService.currentUserId;
          if (myId != null) {
            _statusChannel?.sendBroadcastMessage(
              event: 'peer_lifecycle',
              payload: {
                'user_id': myId,
                'state': 'online',
              },
            );
          }
          _autoRetryFailedMessages();
        }
      });
    }
  }

  void _handlePresenceSync() {
    if (_isBotSession || !mounted) return;
    final myId = SupabaseService.currentUserId;
    final presenceState = _statusChannel?.presenceState();
    if (presenceState == null) return;

    bool foundPartner = false;
    String partnerState = 'disconnected';

    for (final state in presenceState) {
      for (final p in state.presences) {
        final payload = p.payload;
        final uid = payload['user_id'] as String?;
        if (uid != null && uid != myId) {
          foundPartner = true;
          partnerState = payload['presence_state'] as String? ?? 'online';
          break;
        }
      }
      if (foundPartner) break;
    }

    if (!mounted) return;

    if (foundPartner) {
      setState(() {
        _partnerPresenceState = partnerState;
      });
      if (partnerState == 'in_background' || partnerState == 'online') {
        _stopGracePeriodTimer();
      } else {
        _startGracePeriodTimer();
      }
    } else {
      // Periksa apakah masih dalam toleransi startup (15 detik pertama sejak room dibuka)
      final secondsSinceEntry = DateTime.now().difference(_roomEnteredAt).inSeconds;
      if (secondsSinceEntry < 15) {
        // Jangan langsung trigger disconnected jika partner baru proses koneksi/handshake
        return;
      }

      // Jika partner sebelumnya sudah tercatat 'in_background', pertahankan status 'in_background'
      // jangan seketika dialihkan ke 'disconnected' karena websocket di background mobile
      // sering kali disuspend oleh OS saat aplikasi diminimize (di recent apps).
      if (_partnerPresenceState != 'in_background') {
        setState(() {
          _partnerPresenceState = 'disconnected';
        });
        _startGracePeriodTimer();
      }
    }
  }

  void _startGracePeriodTimer() {
    if (_graceTimer != null && _graceTimer!.isActive) return;
    _graceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_graceSecondsRemaining > 1) {
        setState(() {
          _graceSecondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isSessionEnded = true;
        });
        ref.read(anonChatServiceProvider).endSession(widget.sessionId);
      }
    });
  }

  void _stopGracePeriodTimer() {
    _graceTimer?.cancel();
    _graceTimer = null;
    if (mounted) {
      setState(() {
        _graceSecondsRemaining = 90;
      });
    }
  }

  void _broadcastStatus(String status) {
    if (_statusChannel == null) return;
    final myId = SupabaseService.currentUserId ?? 'anon_user';

    if (status == 'typing') {
      _debounceTypingTimer?.cancel();
      ref.read(anonChatServiceProvider).broadcastUserStatus(
        channel: _statusChannel!,
        senderId: myId,
        status: 'typing',
      );
      _debounceTypingTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          ref.read(anonChatServiceProvider).broadcastUserStatus(
            channel: _statusChannel!,
            senderId: myId,
            status: 'idle',
          );
        }
      });
    } else {
      _debounceTypingTimer?.cancel();
      ref.read(anonChatServiceProvider).broadcastUserStatus(
        channel: _statusChannel!,
        senderId: myId,
        status: status,
      );
    }
  }

  void _toggleEmojiKeyboard() {
    if (_showEmoji) {
      _focusNode.requestFocus();
      setState(() {
        _showEmoji = false;
      });
      _broadcastStatus('idle');
    } else {
      _focusNode.unfocus();
      setState(() {
        _showEmoji = true;
      });
      _broadcastStatus('choosing_emoji');
    }
  }

  void _handleIncomingMessagesActivity(List<AnonMessageModel> serverMessages) {
    if (_isSessionEnded || widget.sessionId.isEmpty || widget.sessionId == 'local-session') return;
    final currentUserId = SupabaseService.currentUserId;

    // Cek apakah ada pesan dari partner (bukan diri sendiri dan bukan sistem)
    final partnerMessages = serverMessages.where((m) =>
      !m.isSystem && (m.senderId != null && m.senderId != currentUserId)
    ).toList();

    if (partnerMessages.isNotEmpty) {
      // 1. Activity-based heartbeat: pesan dari partner membuktikan partner 100% online
      if (_partnerPresenceState == 'disconnected') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _partnerPresenceState = 'online';
            });
            _stopGracePeriodTimer();
          }
        });
      } else if (_graceTimer != null && _graceTimer!.isActive) {
        _stopGracePeriodTimer();
      }

      // 2. Read receipts: jika ada pesan partner yang belum dibaca, tandai sebagai terbaca
      final hasUnread = partnerMessages.any((m) => !m.isRead);
      if (hasUnread) {
        ref.read(anonChatServiceProvider).markMessagesAsRead(widget.sessionId);
      }
    }
  }

  List<AnonMessageModel> _combineAnonMessages(List<AnonMessageModel> serverMessages) {
    final currentUserId = SupabaseService.currentUserId;
    final filteredServer = currentUserId != null
        ? serverMessages.where((s) => !s.deletedForUsers.contains(currentUserId)).toList()
        : serverMessages;

    // 1. Hapus optimistic message yang ID-nya sudah ada di filteredServer (Exact UUID match)
    _optimisticMessages.removeWhere((opt) {
      return filteredServer.any((s) => s.id == opt.id);
    });

    final List<AnonMessageModel> items = List.from(filteredServer);

    // 2. Display Guard: Hanya tambahkan optimistic messages yang ID-nya belum ada di items
    // (Deduplikasi berbasis ID unik UUID v4, sehingga pengguna bebas mengirim pesan berulang seperti 'test' 'test')
    for (final opt in _optimisticMessages) {
      final alreadyExists = items.any((m) => m.id == opt.id);
      if (!alreadyExists) {
        items.add(opt);
      }
    }

    // 3. Unique ID Safety Net: Jamin tidak ada ID yang berulang di layar
    final seenIds = <String>{};
    items.retainWhere((m) => seenIds.add(m.id));

    return items;
  }

  void _sendMessage() async {
    if (_isSessionEnded) return;
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _broadcastStatus('idle');

    _textController.clear();

    final userProfile = ref.read(profileProvider);
    final userAlias = 'Mahasiswa ${userProfile.gender == 'Laki-laki' ? 'Bro' : 'Sis'}';
    final currentUserId = SupabaseService.currentUserId;
    final messageId = const Uuid().v4();
    final now = DateTime.now();

    final optimisticMsg = AnonMessageModel(
      id: messageId,
      sessionId: widget.sessionId,
      senderId: currentUserId,
      senderAlias: userAlias,
      messageText: text,
      isSystem: false,
      createdAt: now,
      deliveryStatus: MessageDeliveryStatus.sending,
    );

    setState(() {
      _optimisticMessages.add(optimisticMsg);
    });
    _scrollToBottom();

    if (widget.sessionId.isNotEmpty && widget.sessionId != 'local-session') {
      try {
        final saved = await ref.read(anonChatServiceProvider).sendMessage(
          sessionId: widget.sessionId,
          messageText: text,
          senderAlias: userAlias,
          isBotSession: _isBotSession,
          mode: widget.mode,
          messageId: messageId,
        );
        if (mounted) {
          setState(() {
            final idx = _optimisticMessages.indexWhere((m) => m.id == messageId);
            if (idx != -1) {
              _optimisticMessages[idx] = (saved ?? optimisticMsg).copyWith(
                deliveryStatus: MessageDeliveryStatus.sent,
              );
            }
          });
        }
      } catch (e) {
        final isDuplicateKey = e.toString().contains('23505') ||
            e.toString().toLowerCase().contains('duplicate key');
        if (mounted) {
          setState(() {
            final idx = _optimisticMessages.indexWhere((m) => m.id == messageId);
            if (idx != -1) {
              _optimisticMessages[idx] = optimisticMsg.copyWith(
                deliveryStatus: isDuplicateKey
                    ? MessageDeliveryStatus.sent
                    : MessageDeliveryStatus.failed,
              );
            }
          });
        }
      }
    } else {
      // local demo
      setState(() {
        final idx = _optimisticMessages.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          _optimisticMessages[idx] = optimisticMsg.copyWith(
            deliveryStatus: MessageDeliveryStatus.sent,
          );
        }
      });

      // Simulasi balasan anonim otomatis lokal
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _fallbackMessages.add({
              'id': const Uuid().v4(),
              'text': 'Terima kasih sudah mau berbagi. Aku dengarkan kok, silakan lanjut ceritanya...',
              'isMe': false,
              'time': 'Sekarang',
            });
          });
          _scrollToBottom();
        }
      });
    }
  }

  Future<void> _autoRetryFailedMessages() async {
    if (_isAutoRetrying || !mounted) return;

    final failedList = _optimisticMessages
        .where((m) => m.deliveryStatus == MessageDeliveryStatus.failed)
        .toList();
    if (failedList.isEmpty) return;

    _isAutoRetrying = true;
    try {
      for (final msg in failedList) {
        if (!mounted) break;
        final stillFailed = _optimisticMessages.any(
          (m) => m.id == msg.id && m.deliveryStatus == MessageDeliveryStatus.failed,
        );
        if (stillFailed) {
          await _retrySendMessage(msg);
          await Future.delayed(const Duration(milliseconds: 250));
        }
      }
    } finally {
      if (mounted) {
        _isAutoRetrying = false;
      }
    }
  }

  Future<void> _retrySendMessage(AnonMessageModel message) async {
    // Cegah duplikasi proses jika pesan sudah sedang dikirimkan (sending)
    final existingIdx = _optimisticMessages.indexWhere((m) => m.id == message.id);
    if (existingIdx != -1 &&
        _optimisticMessages[existingIdx].deliveryStatus == MessageDeliveryStatus.sending) {
      return;
    }

    final retryTime = DateTime.now();
    setState(() {
      final idx = _optimisticMessages.indexWhere((m) => m.id == message.id);
      if (idx != -1) {
        _optimisticMessages[idx] = message.copyWith(
          createdAt: retryTime,
          deliveryStatus: MessageDeliveryStatus.sending,
        );
      }
    });

    try {
      final saved = await ref.read(anonChatServiceProvider).sendMessage(
        sessionId: widget.sessionId,
        messageText: message.messageText,
        senderAlias: message.senderAlias,
        isBotSession: _isBotSession,
        mode: widget.mode,
        messageId: message.id,
      );
      if (mounted) {
        setState(() {
          final idx = _optimisticMessages.indexWhere((m) => m.id == message.id);
          if (idx != -1) {
            _optimisticMessages[idx] = (saved ?? message).copyWith(
              createdAt: retryTime,
              deliveryStatus: MessageDeliveryStatus.sent,
            );
          }
        });
      }
    } catch (e) {
      final isDuplicateKey = e.toString().contains('23505') ||
          e.toString().toLowerCase().contains('duplicate key');
      if (mounted) {
        setState(() {
          final idx = _optimisticMessages.indexWhere((m) => m.id == message.id);
          if (idx != -1) {
            _optimisticMessages[idx] = message.copyWith(
              createdAt: retryTime,
              deliveryStatus: isDuplicateKey
                  ? MessageDeliveryStatus.sent
                  : MessageDeliveryStatus.failed,
            );
          }
        });
      }
    }
  }

  void _deleteOptimisticMessage(AnonMessageModel message) {
    setState(() {
      _optimisticMessages.removeWhere((m) => m.id == message.id);
    });
  }

  void _showFailedMessageOptions(BuildContext context, AnonMessageModel message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded, color: AppColors.twilightDarker),
                  title: const Text('Kirim Ulang Pesan', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Coba kirim ulang pesan ini ke obrolan'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _retrySendMessage(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.redNormal),
                  title: const Text('Hapus Pesan', style: TextStyle(color: AppColors.redNormal, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _deleteOptimisticMessage(message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSelectMessage(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedMessageIds.contains(id)) {
        _selectedMessageIds.remove(id);
      } else {
        _selectedMessageIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  void _copySelectedMessages(List<AnonMessageModel> messages) {
    final selected = messages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    if (selected.isEmpty) return;

    selected.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final buffer = StringBuffer();
    for (int i = 0; i < selected.length; i++) {
      final m = selected[i];
      final timeStr = _formatMessageTime(m.createdAt);
      final textContent = m.isDeletedForEveryone ? 'Pesan ini telah ditarik' : m.messageText;
      buffer.write('[$timeStr] $textContent');
      if (i < selected.length - 1) {
        buffer.write('\n');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    _clearSelection();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selected.length == 1
              ? 'Teks pesan disalin ke papan klip'
              : '${selected.length} pesan disalin ke papan klip',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteOptionsModal(BuildContext context, List<AnonMessageModel> messages) {
    final currentUserId = SupabaseService.currentUserId;
    final selected = messages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    if (selected.isEmpty) return;

    final allSentByMe = selected.every((m) => m.senderId != null && m.senderId == currentUserId);
    final anyAlreadyUnsent = selected.any((m) => m.isDeletedForEveryone);
    final canUnsend = allSentByMe && !anyAlreadyUnsent;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Hapus Pesan (${selected.length})',
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (canUnsend)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.redNormal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: AppColors.redNormal),
                    ),
                    title: const Text(
                      'Tarik untuk Semua Orang',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.redNormal),
                    ),
                    subtitle: const Text(
                      'Pesan akan ditarik dari ruang obrolan untuk semua orang',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _executeUnsendMessages(selected);
                    },
                  ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.twilightDarker.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.twilightDarker),
                  ),
                  title: const Text(
                    'Hapus untuk Saya',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.twilightDarker),
                  ),
                  subtitle: Text(
                    canUnsend
                        ? 'Pesan hanya akan dihapus dari perangkat Anda'
                        : 'Pesan terpilih akan dihapus dari riwayat obrolan Anda',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _executeDeleteForMeMessages(selected);
                  },
                ),
                ListTile(
                  leading: const SizedBox(width: 40),
                  title: Center(
                    child: Text(
                      'Batal',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.twilightNormal),
                    ),
                  ),
                  onTap: () => Navigator.of(bottomSheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _executeDeleteForMeMessages(List<AnonMessageModel> selected) {
    final selectedIds = selected.map((m) => m.id).toSet();
    setState(() {
      _optimisticMessages.removeWhere((m) => selectedIds.contains(m.id));
      _cachedAnonMessages.removeWhere((m) => selectedIds.contains(m.id));
      _selectedMessageIds.clear();
    });

    final serverIds = selected
        .where((m) => m.id.isNotEmpty && m.id != '1')
        .map((m) => m.id)
        .toList();

    if (serverIds.isNotEmpty) {
      ref.read(anonChatServiceProvider).deleteMessagesForMe(serverIds);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan berhasil dihapus untuk Anda'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _executeUnsendMessages(List<AnonMessageModel> selected) {
    final selectedIds = selected.map((m) => m.id).toSet();
    setState(() {
      _optimisticMessages.removeWhere((m) => selectedIds.contains(m.id));
      _cachedAnonMessages = _cachedAnonMessages.map((m) {
        if (selectedIds.contains(m.id)) {
          return m.copyWith(isDeletedForEveryone: true);
        }
        return m;
      }).toList();
      _selectedMessageIds.clear();
    });

    final serverIds = selected
        .where((m) => m.id.isNotEmpty && m.id != '1')
        .map((m) => m.id)
        .toList();

    if (serverIds.isNotEmpty) {
      ref.read(anonChatServiceProvider).unsendMessagesForEveryone(serverIds);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan berhasil ditarik'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDeliveryStatusIcon(MessageDeliveryStatus status) {
    switch (status) {
      case MessageDeliveryStatus.sending:
        return const Icon(
          Icons.access_time_rounded,
          size: 11,
          color: Colors.white70,
        );
      case MessageDeliveryStatus.failed:
        return const Icon(
          Icons.error_outline_rounded,
          size: 13,
          color: Colors.redAccent,
        );
      case MessageDeliveryStatus.read:
        return const Icon(
          Icons.done_all_rounded,
          size: 13,
          color: Colors.cyanAccent,
        );
      case MessageDeliveryStatus.sent:
        return const Icon(
          Icons.done_all_rounded,
          size: 13,
          color: Colors.white70,
        );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMessageTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<AnonMessageModel> _getCurrentCombinedMessages() {
    return _combineAnonMessages(_cachedAnonMessages);
  }

  Widget _buildContextualActionBar() {
    final currentMessages = _getCurrentCombinedMessages();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.twilightDarker),
            tooltip: 'Batal',
            onPressed: _clearSelection,
          ),
          const SizedBox(width: 8),
          Text(
            '${_selectedMessageIds.length} dipilih',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.twilightDarker),
            tooltip: 'Salin',
            onPressed: () => _copySelectedMessages(currentMessages),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.redNormal),
            tooltip: 'Hapus',
            onPressed: () => _showDeleteOptionsModal(context, currentMessages),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.currentUserId;
    final isRealSession = widget.sessionId.isNotEmpty && widget.sessionId != 'local-session';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selectedMessageIds.isNotEmpty) {
          _clearSelection();
          return;
        }
        if (_showEmoji) {
          setState(() {
            _showEmoji = false;
          });
        } else {
          _showLeaveChatDialog(context);
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.wisteriaLight,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            if (_selectedMessageIds.isNotEmpty)
              _buildContextualActionBar()
            else
              Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showLeaveChatDialog(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.twilightDarker,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Mascot Avatar
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.twilightNormal, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isBotSession
                                ? Colors.green
                                : (_partnerPresenceState == 'online'
                                    ? Colors.green
                                    : (_partnerPresenceState == 'in_background'
                                        ? Colors.amber
                                        : Colors.grey)),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // Title & Mode / Subtitle Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat Anon',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_peerStatus == 'typing')
                          Text(
                            'sedang mengetik...',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.wisteriaNormalHover,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          )
                        else if (_peerStatus == 'choosing_emoji')
                          Text(
                            'sedang memilih emoji... 😊',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.wisteriaNormalHover,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          )
                        else if (!_isBotSession && _partnerPresenceState == 'in_background')
                          Text(
                            'sedang di luar aplikasi... 🟡',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          )
                        else if (!_isBotSession && _partnerPresenceState == 'disconnected')
                          Text(
                            'terputus... ($_graceSecondsRemaining dtk) ⚪',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.redNormalHover,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          )
                        else
                          Text(
                            widget.mode,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.wisteriaNormalHover,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // 3-dots Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.twilightDarker),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'report') {
                        _showReportDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            const Icon(Icons.report_problem_outlined, size: 20, color: AppColors.twilightDarker),
                            const SizedBox(width: 8),
                            Text(
                              'Laporkan chat',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.twilightDarker,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Grace Period Disconnect Notice Banner
            if (!_isBotSession && !_isSessionEnded && _partnerPresenceState == 'disconnected')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.amber.shade50,
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 16, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Partner terputus. Menunggu kembali ($_graceSecondsRemaining dtk)...',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showLeaveChatDialog(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cari Baru',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.redNormalHover,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Offline Connection Notice Banner
            if (!_isStreamConnected && _cachedAnonMessages.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                color: Colors.amber.shade100.withValues(alpha: 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 14, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Text(
                      'Menghubungkan kembali... Menampilkan riwayat tersimpan',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Chat Messages List
            Expanded(
              child: isRealSession
                  ? StreamBuilder<List<AnonMessageModel>>(
                      stream: _messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          _cachedAnonMessages = snapshot.data!;
                          _isStreamConnected = true;
                          _handleIncomingMessagesActivity(snapshot.data!);
                        } else if (snapshot.hasError) {
                          _isStreamConnected = false;
                        }

                        final serverMessages = _cachedAnonMessages.isNotEmpty
                            ? _cachedAnonMessages
                            : (snapshot.data ?? []);
                        final messages = _combineAnonMessages(serverMessages);

                        if (messages.isNotEmpty) {
                          _scrollToBottom();
                        }

                        if (messages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Kamu terhubung secara anonim. Mulai percakapan dengan santai dan bebas ✨',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.twilightNormal.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          );
                        }

                        if (messages.length != _lastMessageCount) {
                          _lastMessageCount = messages.length;
                          _scrollToBottom();
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            if (msg.isSystem) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    msg.messageText,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.twilightDarker,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            final isMe = msg.senderId != null
                                ? msg.senderId == currentUserId
                                : false;
                            final isFailed = isMe && msg.deliveryStatus == MessageDeliveryStatus.failed;
                            final isSelected = _selectedMessageIds.contains(msg.id);
                            final isUnsent = msg.isDeletedForEveryone;

                            if (isUnsent) {
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: GestureDetector(
                                  onLongPress: () => _toggleSelectMessage(msg.id),
                                  onTap: () {
                                    if (_selectedMessageIds.isNotEmpty) {
                                      _toggleSelectMessage(msg.id);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : (isMe
                                              ? AppColors.twilightDarker.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.05)),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isMe
                                                ? AppColors.twilightNormal.withValues(alpha: 0.25)
                                                : Colors.black12),
                                        width: isSelected ? 1.8 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_selectedMessageIds.isNotEmpty) ...[
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle_rounded
                                                : Icons.radio_button_unchecked_rounded,
                                            size: 18,
                                            color: isSelected ? AppColors.primary : AppColors.twilightLight,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Icon(
                                          Icons.block_rounded,
                                          size: 15,
                                          color: isMe ? AppColors.twilightNormal : Colors.black45,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            isMe ? 'Anda telah menarik pesan ini' : 'Pesan ini telah ditarik',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: isMe ? AppColors.twilightNormal : Colors.black54,
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatMessageTime(msg.createdAt),
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.black38,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: GestureDetector(
                                onLongPress: isFailed ? null : () => _toggleSelectMessage(msg.id),
                                onTap: () {
                                  if (_selectedMessageIds.isNotEmpty) {
                                    _toggleSelectMessage(msg.id);
                                    return;
                                  }
                                  if (isFailed) {
                                    _showFailedMessageOptions(context, msg);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isFailed
                                        ? const Color(0xFF6B2D2D)
                                        : (isSelected
                                            ? (isMe ? AppColors.twilightDarker.withValues(alpha: 0.85) : AppColors.wisteriaLight)
                                            : (isMe ? AppColors.twilightDarker : Colors.white)),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 18),
                                    ),
                                    border: isSelected
                                        ? Border.all(color: AppColors.primary, width: 2)
                                        : (isFailed ? Border.all(color: Colors.redAccent.shade100, width: 1.2) : null),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (_selectedMessageIds.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? Icons.check_circle_rounded
                                                    : Icons.radio_button_unchecked_rounded,
                                                size: 16,
                                                color: isSelected
                                                    ? (isMe ? Colors.white : AppColors.primary)
                                                    : (isMe ? Colors.white54 : AppColors.twilightLight),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isSelected ? 'Dipilih' : 'Pilih',
                                                style: AppTextStyles.labelSmall.copyWith(
                                                  color: isMe ? Colors.white70 : AppColors.twilightNormal,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        msg.messageText,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: isMe ? Colors.white : AppColors.twilightDarker,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatMessageTime(msg.createdAt),
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: isMe ? Colors.white70 : AppColors.twilightNormal,
                                              fontSize: 10,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            _buildDeliveryStatusIcon(msg.deliveryStatus),
                                          ],
                                        ],
                                      ),
                                      if (isFailed) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Gagal terkirim. Ketuk untuk kirim ulang',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.red.shade200,
                                            fontSize: 9,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: _fallbackMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _fallbackMessages[index];
                        final isMe = msg['isMe'] as bool;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.twilightDarker : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(isMe ? 18 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'] as String,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isMe ? Colors.white : AppColors.twilightDarker,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['time'] as String,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isMe ? Colors.white70 : AppColors.twilightNormal,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Input Area / Sesi Berakhir Banner
            if (_isSessionEnded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.redNormalHover, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Obrolan ini telah berakhir',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.twilightDarker,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Partnermu telah meninggalkan percakapan ini.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.wisteriaNormalHover,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.twilightLight),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Kembali ke Menu',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.twilightDarker,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.pop();
                              ChatAnonMatchingRoute(mode: widget.mode).push(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.twilightDarker,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Cari Teman Baru',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: _showEmoji ? 10 : 16),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.twilightNormal.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _showEmoji ? Icons.keyboard_outlined : Icons.sentiment_satisfied_alt,
                          color: AppColors.twilightNormal,
                        ),
                        onPressed: _toggleEmojiKeyboard,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.twilightNormal.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _textController,
                          onChanged: (val) {
                            _broadcastStatus(val.trim().isNotEmpty ? 'typing' : 'idle');
                          },
                          onSubmitted: (_) => _sendMessage(),
                          onTap: () {
                            if (_showEmoji) {
                              setState(() {
                                _showEmoji = false;
                              });
                              _broadcastStatus('idle');
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.twilightNormal.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.wisteriaNormal,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Papan Emoji Keyboard (Tampilan Sangat Rapi & Modern)
              if (_showEmoji)
                Container(
                  height: 290,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: AppColors.twilightNormal.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        height: 290,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: const EmojiViewConfig(
                          backgroundColor: Colors.white,
                          columns: 8,
                          emojiSizeMax: 26,
                          verticalSpacing: 6,
                          horizontalSpacing: 4,
                          gridPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        categoryViewConfig: CategoryViewConfig(
                          tabBarHeight: 44,
                          backgroundColor: Colors.white,
                          indicatorColor: AppColors.wisteriaNormalHover,
                          iconColorSelected: AppColors.wisteriaNormalHover,
                          iconColor: AppColors.twilightNormal.withValues(alpha: 0.4),
                          dividerColor: AppColors.twilightNormal.withValues(alpha: 0.1),
                          backspaceColor: AppColors.wisteriaNormalHover,
                        ),
                        bottomActionBarConfig: BottomActionBarConfig(
                          enabled: true,
                          backgroundColor: Colors.white,
                          buttonColor: AppColors.wisteriaNormalHover.withValues(alpha: 0.12),
                          buttonIconColor: AppColors.wisteriaNormalHover,
                        ),
                        searchViewConfig: const SearchViewConfig(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
  }

  void _showLeaveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LeaveChatDialog(
        onConfirmLeave: () {
          if (widget.sessionId.isNotEmpty && widget.sessionId != 'local-session') {
            ref.read(anonChatServiceProvider).endSession(widget.sessionId);
          }
          ref.invalidate(activeAnonSessionProvider);
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportChatDialog(
        sessionId: widget.sessionId,
        onReportSuccess: () {
          ref.invalidate(activeAnonSessionProvider);
          if (mounted) {
            context.pop();
          }
        },
      ),
    );
  }
}
