import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/counseling_service.dart';
import '../../domain/counseling_models.dart';
import '../widgets/dialogs/counseling_rating_dialog.dart';

class ChatRoomView extends ConsumerStatefulWidget {
  final String counselorName;
  final bool isOnline;
  final String sessionId;

  const ChatRoomView({
    super.key,
    required this.counselorName,
    required this.isOnline,
    this.sessionId = '',
  });

  @override
  ConsumerState<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends ConsumerState<ChatRoomView> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;

  // Nama dan status online konselor (bisa ter-resolve dari DB)
  late String _counselorName;
  late bool _isOnline;

  // Realtime Status Pengetikan / Emoji Lawan Bicara
  String _peerStatus = 'idle';
  Timer? _peerTypingTimer;
  Timer? _debounceTypingTimer;
  RealtimeChannel? _statusChannel;

  // Optimistic UI, Cache Retensi & Tracking Scroll
  final List<ChatMessageModel> _optimisticMessages = [];
  List<ChatMessageModel> _cachedServerMessages = [];
  bool _isStreamConnected = true;
  int _lastMessageCount = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isAutoRetrying = false;
  final Set<String> _selectedMessageIds = {};

  // Realtime Session Listener untuk Akhiri Sesi & Rating
  StreamSubscription<CounselingSessionModel?>? _sessionSubscription;
  bool _hasShownRatingDialog = false;
  bool _isSessionCompleted = false;

  // Pesan lokal sementara sebagai fallback jika belum ada riwayat di database
  final List<Map<String, dynamic>> _fallbackMessages = [
    {
      'id': 'fallback-1',
      'text': 'Halo! Ada yang bisa aku bantu atau mau kamu ceritakan hari ini?',
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
    },
  ];

  Stream<List<ChatMessageModel>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _counselorName = widget.counselorName.isNotEmpty ? widget.counselorName : 'Konselor Sebaya';
    _isOnline = widget.isOnline;

    _cachedServerMessages = ref.read(counselingServiceProvider).getSessionCache(widget.sessionId);
    _resolveCounselorInfo();
    _initStream();
    _initStatusChannel();
    _initSessionListener();
    _markIncomingAsRead();
    _initConnectivityListener();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (_showEmoji) {
          setState(() {
            _showEmoji = false;
          });
          _broadcastStatus('idle');
        }
        _scrollToBottom(animated: true);
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
  void didUpdateWidget(covariant ChatRoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _cachedServerMessages = ref.read(counselingServiceProvider).getSessionCache(widget.sessionId);
      _resolveCounselorInfo();
      _initStream();
      _initStatusChannel();
      _initSessionListener();
      _markIncomingAsRead();
    }
  }

  /// Memperbarui nama konselor asli dari database jika dibuka dari banner atau link luar
  void _resolveCounselorInfo() async {
    if (widget.sessionId.isEmpty) return;
    try {
      final sessionRow = await SupabaseService.client
          .from('counseling_sessions')
          .select('counselor_id')
          .eq('id', widget.sessionId)
          .maybeSingle();

      final counselorId = sessionRow?['counselor_id'] as String?;
      if (counselorId != null && counselorId.isNotEmpty) {
        final profile = await ref.read(counselingServiceProvider).fetchCounselorProfile(counselorId);
        if (profile != null && mounted) {
          final realName = (profile['full_name'] as String?)?.trim();
          final nick = (profile['nickname'] as String?)?.trim();
          final effective = (realName != null && realName.isNotEmpty)
              ? realName
              : (nick != null && nick.isNotEmpty ? nick : null);

          if (effective != null && effective.isNotEmpty) {
            setState(() {
              _counselorName = effective;
              _isOnline = profile['is_online'] as bool? ?? _isOnline;
            });
          }
        }
      }
    } catch (_) {}
  }

  void _markIncomingAsRead() {
    if (widget.sessionId.isNotEmpty) {
      ref.read(counselingServiceProvider).markMessagesAsRead(
        sessionId: widget.sessionId,
        peerRole: 'counselor',
      );
    }
  }

  void _initStream() {
    if (widget.sessionId.isNotEmpty) {
      _messagesStream = ref.read(counselingServiceProvider).streamMessages(widget.sessionId);
    } else {
      _messagesStream = null;
    }
  }

  void _initStatusChannel() {
    if (_statusChannel != null) {
      try {
        SupabaseService.client.removeChannel(_statusChannel!);
      } catch (_) {}
      _statusChannel = null;
    }

    if (widget.sessionId.isNotEmpty) {
      _statusChannel = ref.read(counselingServiceProvider).createChatStatusChannel(widget.sessionId);
      _statusChannel?.onBroadcast(event: 'user_status', callback: (payload) {
        final senderId = payload['sender_id'] as String?;
        final status = payload['status'] as String?;
        final myId = SupabaseService.currentUserId;

        if (senderId != myId && status != null && mounted) {
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
      }).subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _autoRetryFailedMessages();
        }
      });
    }
  }

  void _initSessionListener() {
    _sessionSubscription?.cancel();
    if (widget.sessionId.isNotEmpty) {
      _sessionSubscription = ref.read(counselingServiceProvider).streamSession(widget.sessionId).listen((session) {
        if (session != null && session.status == 'completed' && mounted) {
          setState(() {
            _isSessionCompleted = true;
          });
          if (!_hasShownRatingDialog) {
            _hasShownRatingDialog = true;
            _showRatingDialog();
          }
        }
      });
    }
  }

  void _broadcastStatus(String status) {
    if (_statusChannel == null) return;
    final myId = SupabaseService.currentUserId;
    if (myId == null) return;

    if (status == 'typing') {
      _debounceTypingTimer?.cancel();
      ref.read(counselingServiceProvider).broadcastUserStatus(
        channel: _statusChannel!,
        senderId: myId,
        status: 'typing',
      );
      _debounceTypingTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          ref.read(counselingServiceProvider).broadcastUserStatus(
            channel: _statusChannel!,
            senderId: myId,
            status: 'idle',
          );
        }
      });
    } else {
      _debounceTypingTimer?.cancel();
      ref.read(counselingServiceProvider).broadcastUserStatus(
        channel: _statusChannel!,
        senderId: myId,
        status: status,
      );
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => CounselingRatingDialog(
        sessionId: widget.sessionId,
        counselorName: _counselorName,
        onSubmitted: () {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Terima kasih atas ulasanmu! Sesi konseling telah selesai ✨'),
                backgroundColor: AppColors.twilightDarker,
              ),
            );
          }
        },
        onSkipped: () {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi konseling telah selesai.'),
                backgroundColor: AppColors.twilightDarker,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEndSessionConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isEnding = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.redNormal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.exit_to_app_rounded,
                        color: AppColors.redNormal,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Akhiri Sesi Konseling?',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.twilightDarker,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Kamu dapat mengakhiri sesi ini kapan saja jika merasa sudah cukup atau kurang nyaman. Sesi akan diselesaikan dan kamu dapat memberikan ulasan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.twilightDark,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isEnding ? null : () => Navigator.of(dialogCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.twilightNormal.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            child: Text(
                              'Lanjutkan Chat',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.twilightDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isEnding
                                ? null
                                : () async {
                                    setDialogState(() {
                                      isEnding = true;
                                    });
                                    Navigator.of(dialogCtx).pop();
                                    await _handleEndSessionByStudent();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.redNormal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                            child: isEnding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Akhiri Sesi',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleEndSessionByStudent() async {
    if (widget.sessionId.isEmpty) return;
    try {
      await ref.read(counselingServiceProvider).endSession(widget.sessionId);
      if (mounted) {
        setState(() {
          _isSessionCompleted = true;
        });
        if (!_hasShownRatingDialog) {
          _hasShownRatingDialog = true;
          _showRatingDialog();
        }
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _autoRetryFailedMessages();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _peerTypingTimer?.cancel();
    _debounceTypingTimer?.cancel();
    _sessionSubscription?.cancel();
    if (_statusChannel != null) {
      try {
        SupabaseService.client.removeChannel(_statusChannel!);
      } catch (_) {}
    }
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    _scrollToBottom(animated: true);
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final target = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(target);
        }
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _broadcastStatus('idle');

    final currentUserId = SupabaseService.currentUserId;
    final messageId = const Uuid().v4();
    final now = DateTime.now();

    // 1. Optimistic UI: Tampilkan langsung di layar
    final optimisticMsg = ChatMessageModel(
      id: messageId,
      sessionId: widget.sessionId,
      senderId: currentUserId ?? 'student',
      senderRole: 'student',
      messageText: text,
      isRead: false,
      createdAt: now,
      deliveryStatus: MessageDeliveryStatus.sending,
    );

    setState(() {
      _optimisticMessages.add(optimisticMsg);
    });
    _scrollToBottom(animated: true);

    if (widget.sessionId.isNotEmpty && currentUserId != null) {
      try {
        final savedMsg = await ref.read(counselingServiceProvider).sendMessage(
          sessionId: widget.sessionId,
          senderId: currentUserId,
          senderRole: 'student',
          messageText: text,
          messageId: messageId,
        );
        // Transisi mulus: jangan hapus langsung agar tidak ada jeda kosong / kedip sebelum stream tiba.
        // Update status pesan lokal menjadi sent.
        if (mounted) {
          setState(() {
            final idx = _optimisticMessages.indexWhere((m) => m.id == messageId);
            if (idx != -1) {
              _optimisticMessages[idx] = savedMsg.copyWith(
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
      // Fallback offline / local demo
      setState(() {
        _fallbackMessages.add({
          'id': messageId,
          'text': text,
          'isMe': true,
          'time': now,
        });
        _optimisticMessages.removeWhere((m) => m.id == messageId);
      });
      _scrollToBottom(animated: true);
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
          await _retrySendMessage(msg.id);
          await Future.delayed(const Duration(milliseconds: 250));
        }
      }
    } finally {
      if (mounted) {
        _isAutoRetrying = false;
      }
    }
  }

  Future<void> _retrySendMessage(String messageId) async {
    final idx = _optimisticMessages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = _optimisticMessages[idx];
    if (msg.deliveryStatus == MessageDeliveryStatus.sending) return;

    final currentUserId = SupabaseService.currentUserId;
    final retryTime = DateTime.now();

    setState(() {
      _optimisticMessages[idx] = msg.copyWith(
        createdAt: retryTime,
        deliveryStatus: MessageDeliveryStatus.sending,
      );
    });

    if (widget.sessionId.isNotEmpty && currentUserId != null) {
      try {
        final savedMsg = await ref.read(counselingServiceProvider).sendMessage(
          sessionId: widget.sessionId,
          senderId: currentUserId,
          senderRole: 'student',
          messageText: msg.messageText,
          messageId: messageId,
        );
        if (mounted) {
          setState(() {
            final reIdx = _optimisticMessages.indexWhere((m) => m.id == messageId);
            if (reIdx != -1) {
              _optimisticMessages[reIdx] = savedMsg.copyWith(
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
            final reIdx = _optimisticMessages.indexWhere((m) => m.id == messageId);
            if (reIdx != -1) {
              _optimisticMessages[reIdx] = msg.copyWith(
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
  }

  void _deleteOptimisticMessage(String messageId) {
    setState(() {
      _optimisticMessages.removeWhere((m) => m.id == messageId);
    });
  }

  void _showFailedMessageOptions(BuildContext context, String messageId) {
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
                  subtitle: const Text('Coba kirim ulang pesan konseling ini'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _retrySendMessage(messageId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.redNormal),
                  title: const Text('Hapus Pesan', style: TextStyle(color: AppColors.redNormal, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _deleteOptimisticMessage(messageId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_MessageItemData> _combineMessages(List<ChatMessageModel> serverMessages) {
    final currentUserId = SupabaseService.currentUserId;
    final filteredServer = currentUserId != null
        ? serverMessages.where((s) => !s.deletedForUsers.contains(currentUserId)).toList()
        : serverMessages;

    final List<_MessageItemData> items = [];

    for (final m in filteredServer) {
      items.add(_MessageItemData(
        id: m.id,
        text: m.messageText,
        isMe: m.senderId == currentUserId || m.senderRole == 'student',
        time: m.createdAt.toLocal(),
        deliveryStatus: m.isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
        isDeletedForEveryone: m.isDeletedForEveryone,
        senderId: m.senderId,
        deletedForUsers: m.deletedForUsers,
      ));
    }

    // 1. Hapus optimistic message yang ID-nya sudah ada di filteredServer (Exact UUID match)
    _optimisticMessages.removeWhere((opt) {
      return filteredServer.any((s) => s.id == opt.id);
    });

    // 2. Display Guard: Hanya tambahkan optimistic messages yang ID-nya belum ada di items
    for (final opt in _optimisticMessages) {
      final alreadyExists = items.any((m) => m.id == opt.id);
      if (!alreadyExists) {
        items.add(_MessageItemData(
          id: opt.id,
          text: opt.messageText,
          isMe: true,
          time: opt.createdAt.toLocal(),
          deliveryStatus: opt.deliveryStatus,
          isDeletedForEveryone: opt.isDeletedForEveryone,
          senderId: currentUserId,
          deletedForUsers: opt.deletedForUsers,
        ));
      }
    }

    // 3. Unique ID Safety Net - jamin tidak ada ID yang berulang di layar
    final seenIds = <String>{};
    items.retainWhere((m) => seenIds.add(m.id));

    return items;
  }

  List<_MessageItemData> _getCurrentCombinedMessages() {
    return _combineMessages(_cachedServerMessages);
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

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _copySelectedMessages(List<_MessageItemData> messages) {
    final selected = messages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    if (selected.isEmpty) return;

    selected.sort((a, b) => a.time.compareTo(b.time));
    final buffer = StringBuffer();
    for (int i = 0; i < selected.length; i++) {
      final m = selected[i];
      final timeStr = _formatTime(m.time);
      final textContent = m.isDeletedForEveryone ? 'Pesan ini telah ditarik' : m.text;
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

  void _showDeleteOptionsModal(BuildContext context, List<_MessageItemData> messages) {
    final selected = messages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    if (selected.isEmpty) return;

    final allSentByMe = selected.every((m) => m.isMe);
    final anyAlreadyUnsent = selected.any((m) => m.isDeletedForEveryone);
    // Batas waktu unsend konseling: maksimal 30 menit
    final allWithin30Mins = selected.every(
      (m) => DateTime.now().difference(m.time).inMinutes <= 30,
    );
    final canUnsend = allSentByMe && !anyAlreadyUnsent && allWithin30Mins;

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
                      'Pesan akan ditarik dari sesi obrolan untuk semua orang',
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

  void _executeDeleteForMeMessages(List<_MessageItemData> selected) {
    final selectedIds = selected.map((m) => m.id).toSet();
    setState(() {
      _optimisticMessages.removeWhere((m) => selectedIds.contains(m.id));
      _cachedServerMessages.removeWhere((m) => selectedIds.contains(m.id));
      _selectedMessageIds.clear();
    });

    final serverIds = selected
        .where((m) => m.id.isNotEmpty && !m.id.startsWith('fallback-'))
        .map((m) => m.id)
        .toList();

    if (serverIds.isNotEmpty) {
      ref.read(counselingServiceProvider).deleteMessagesForMe(serverIds);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan berhasil dihapus untuk Anda'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _executeUnsendMessages(List<_MessageItemData> selected) {
    final selectedIds = selected.map((m) => m.id).toSet();
    setState(() {
      _optimisticMessages.removeWhere((m) => selectedIds.contains(m.id));
      _cachedServerMessages = _cachedServerMessages.map((m) {
        if (selectedIds.contains(m.id)) {
          return m.copyWith(isDeletedForEveryone: true);
        }
        return m;
      }).toList();
      _selectedMessageIds.clear();
    });

    final serverIds = selected
        .where((m) => m.id.isNotEmpty && !m.id.startsWith('fallback-'))
        .map((m) => m.id)
        .toList();

    if (serverIds.isNotEmpty) {
      ref.read(counselingServiceProvider).unsendMessagesForEveryone(serverIds);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan berhasil ditarik'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    return PopScope(
      canPop: !_showEmoji && _selectedMessageIds.isEmpty,
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
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lavender.withValues(alpha: 0.3),
        appBar: _selectedMessageIds.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: SafeArea(child: _buildContextualActionBar()),
              )
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.twilightDarker),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
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
                  if (_isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _counselorName,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.twilightDarker,
                        fontSize: 16,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    _buildStatusSubtitle(),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (!_isSessionCompleted)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.twilightDarker),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'end_session') {
                    _showEndSessionConfirmationDialog();
                  } else if (val == 'info') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesi konseling aman & terenkripsi')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'end_session',
                    child: Row(
                      children: [
                        const Icon(Icons.exit_to_app_rounded, color: AppColors.redNormal, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Akhiri Sesi Konseling',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.redNormal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'info',
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.twilightDark, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Privasi & Enkripsi',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.twilightDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.twilightDarker),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesi konseling telah diselesaikan')),
                  );
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // Offline Connection Notice Banner
            if (!_isStreamConnected && _cachedServerMessages.isNotEmpty)
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

            // Area Percakapan Realtime
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_showEmoji) {
                    setState(() {
                      _showEmoji = false;
                    });
                    _broadcastStatus('idle');
                  }
                  FocusScope.of(context).unfocus();
                },
                child: widget.sessionId.isNotEmpty
                    ? StreamBuilder<List<ChatMessageModel>>(
                        stream: _messagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            _cachedServerMessages = snapshot.data!;
                            _isStreamConnected = true;
                            ref.read(counselingServiceProvider).updateSessionCache(widget.sessionId, _cachedServerMessages);
                          } else if (snapshot.hasError) {
                            _isStreamConnected = false;
                          }

                          final activeMessages = _cachedServerMessages.isNotEmpty
                              ? _cachedServerMessages
                              : (snapshot.data ?? []);
                          final combined = _combineMessages(activeMessages);

                          if (combined.isEmpty) {
                            final fallbackList = _fallbackMessages.map((m) {
                              return _MessageItemData(
                                id: m['id'] as String,
                                text: m['text'] as String,
                                isMe: m['isMe'] as bool,
                                time: (m['time'] as DateTime).toLocal(),
                                deliveryStatus: MessageDeliveryStatus.sent,
                              );
                            }).toList();
                            return _buildMessageList(fallbackList);
                          }

                          if (combined.length != _lastMessageCount) {
                            _lastMessageCount = combined.length;
                            _scrollToBottom(animated: true);
                            _markIncomingAsRead();
                          }

                          return _buildMessageList(combined);
                        },
                      )
                    : _buildMessageList(
                        _combineMessages([]).isNotEmpty
                            ? _combineMessages([])
                            : _fallbackMessages.map((m) {
                                return _MessageItemData(
                                  id: m['id'] as String,
                                  text: m['text'] as String,
                                  isMe: m['isMe'] as bool,
                                  time: (m['time'] as DateTime).toLocal(),
                                  deliveryStatus: MessageDeliveryStatus.sent,
                                );
                              }).toList(),
                      ),
              ),
            ),

            // Bottom Input Bar or Completed Banner
            if (_isSessionCompleted)
              _buildCompletedSessionBanner()
            else
              Container(
              padding: EdgeInsets.fromLTRB(20, 8, 20, _showEmoji ? 8 : 24),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.platinum,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.twilightNormal.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.twilightDarker.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showEmoji ? Icons.keyboard_outlined : Icons.emoji_emotions_outlined,
                        color: AppColors.wisteriaNormalHover,
                        size: 28,
                      ),
                      onPressed: _toggleEmojiKeyboard,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.twilightNormal.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _messageController,
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
                          _scrollToBottom(animated: true);
                        },
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.twilightNormal.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.wisteriaNormalHover,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Papan Emoji Keyboard (Tampilan Sangat Rapi & Modern)
            if (_showEmoji && !_isSessionCompleted)
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
                    textEditingController: _messageController,
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
        ),
      ),
    );
  }

  Widget _buildCompletedSessionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.platinum,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.wisteriaNormal.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDarker.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.wisteriaNormal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sesi konseling telah selesai.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.twilightDarker,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wisteriaNormal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Kembali',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSubtitle() {
    if (_peerStatus == 'typing') {
      return Text(
        'sedang mengetik...',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.wisteriaNormalHover,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      );
    }
    if (_peerStatus == 'choosing_emoji') {
      return Text(
        'sedang memilih emoji... 😊',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.wisteriaNormalHover,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: _isOnline ? Colors.greenAccent[700] : AppColors.twilightNormal.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _isOnline ? 'Online' : 'Offline',
          style: AppTextStyles.bodySmall.copyWith(
            color: _isOnline ? Colors.green[700] : AppColors.twilightNormal.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList(List<_MessageItemData> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMessageBubble(message),
        );
      },
    );
  }

  Widget _buildMessageBubble(_MessageItemData message) {
    final isMe = message.isMe;
    final isFailed = isMe && message.deliveryStatus == MessageDeliveryStatus.failed;
    final isSelected = _selectedMessageIds.contains(message.id);
    final isUnsent = message.isDeletedForEveryone;
    final localTime = message.time.toLocal();
    final timeStr =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    if (isUnsent) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () => _toggleSelectMessage(message.id),
          onTap: () {
            if (_selectedMessageIds.isNotEmpty) {
              _toggleSelectMessage(message.id);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
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
                  timeStr,
                  style: AppTextStyles.bodySmall.copyWith(
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

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.twilightNormal, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        GestureDetector(
          onLongPress: isFailed ? null : () => _toggleSelectMessage(message.id),
          onTap: () {
            if (_selectedMessageIds.isNotEmpty) {
              _toggleSelectMessage(message.id);
              return;
            }
            if (isFailed) {
              _showFailedMessageOptions(context, message.id);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 14, 8),
            decoration: BoxDecoration(
              color: isFailed
                  ? const Color(0xFF6B2D2D)
                  : (isSelected
                      ? (isMe ? AppColors.twilightDarker.withValues(alpha: 0.85) : AppColors.wisteriaLight)
                      : (isMe ? AppColors.twilightDarker : Colors.white)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
              ),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : (isFailed ? Border.all(color: Colors.redAccent.shade100, width: 1.2) : null),
              boxShadow: [
                if (!isMe)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  message.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isMe ? Colors.white : AppColors.twilightDarker,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      timeStr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isMe ? Colors.white60 : AppColors.twilightNormal.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildDeliveryStatusIcon(message.deliveryStatus),
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
      ],
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
          size: 14,
          color: Colors.cyanAccent,
        );
      case MessageDeliveryStatus.sent:
        return const Icon(
          Icons.done_all_rounded,
          size: 14,
          color: Colors.white70,
        );
    }
  }
}

class _MessageItemData {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageDeliveryStatus deliveryStatus;
  final bool isDeletedForEveryone;
  final String? senderId;
  final List<String> deletedForUsers;

  _MessageItemData({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.deliveryStatus,
    this.isDeletedForEveryone = false,
    this.senderId,
    this.deletedForUsers = const [],
  });
}
