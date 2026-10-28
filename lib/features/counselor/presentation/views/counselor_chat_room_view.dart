import 'dart:async';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../chat/data/counseling_service.dart';
import '../../../chat/domain/counseling_models.dart';
import '../../domain/counselor_model.dart';
import '../providers/counselor_provider.dart';
import '../widgets/anonymous_avatar.dart';

class CounselorChatRoomView extends ConsumerStatefulWidget {
  final String sessionId;
  final String studentTitle;

  const CounselorChatRoomView({
    super.key,
    this.sessionId = 'session-1',
    this.studentTitle = 'Anonym - FILKOM',
  });

  @override
  ConsumerState<CounselorChatRoomView> createState() => _CounselorChatRoomViewState();
}

class _CounselorChatRoomViewState extends ConsumerState<CounselorChatRoomView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;

  late String _studentTitle;
  int _lastMessageCount = 0;

  // Realtime Status Pengetikan / Emoji Mahasiswa
  String _peerStatus = 'idle';
  Timer? _peerTypingTimer;
  Timer? _debounceTypingTimer;
  RealtimeChannel? _statusChannel;

  Stream<List<ChatMessageModel>>? _messagesStream;
  List<ChatMessageModel> _cachedDbMessages = [];
  bool _isStreamConnected = true;

  StreamSubscription<CounselingSessionModel?>? _sessionSubscription;
  bool _isSessionCompleted = false;
  bool _isEndingSession = false;

  // Seleksi Pesan (Copy, Delete for Me, Unsend for Everyone)
  final Set<String> _selectedMessageIds = {};
  final Set<String> _deletedForMeLocalIds = {};
  final Set<String> _unsentLocalIds = {};

  @override
  void initState() {
    super.initState();
    _studentTitle = widget.studentTitle;
    _cachedDbMessages = List<ChatMessageModel>.from(
      ref.read(counselingServiceProvider).getSessionCache(widget.sessionId),
    );
    _resolveStudentInfo();
    _initStream();
    _initStatusChannel();
    _initSessionListener();
    _markIncomingAsRead();

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

  @override
  void didUpdateWidget(covariant CounselorChatRoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _cachedDbMessages = List<ChatMessageModel>.from(
        ref.read(counselingServiceProvider).getSessionCache(widget.sessionId),
      );
      _resolveStudentInfo();
      _initStream();
      _initStatusChannel();
      _initSessionListener();
      _markIncomingAsRead();
    }
  }

  void _initSessionListener() {
    _sessionSubscription?.cancel();
    if (widget.sessionId.isNotEmpty && widget.sessionId != 'session-1') {
      _sessionSubscription = ref.read(counselingServiceProvider).streamSession(widget.sessionId).listen((session) {
        if (session != null && session.status == 'completed' && mounted) {
          if (!_isSessionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi konseling telah diselesaikan.'),
                duration: Duration(seconds: 4),
              ),
            );
          }
          setState(() {
            _isSessionCompleted = true;
          });
        }
      });
    }
  }

  void _resolveStudentInfo() async {
    if (widget.sessionId.isEmpty || widget.sessionId == 'session-1') return;
    try {
      final sessionRow = await SupabaseService.client
          .from('counseling_sessions')
          .select('student_alias, student_faculty')
          .eq('id', widget.sessionId)
          .maybeSingle();

      if (sessionRow != null && mounted) {
        final alias = sessionRow['student_alias'] as String? ?? 'Anonym';
        final faculty = sessionRow['student_faculty'] as String? ?? 'FILKOM';
        setState(() {
          _studentTitle = '$alias - $faculty';
        });
      }
    } catch (_) {}
  }

  void _markIncomingAsRead() {
    if (widget.sessionId.isNotEmpty && widget.sessionId != 'session-1') {
      ref.read(counselingServiceProvider).markMessagesAsRead(
        sessionId: widget.sessionId,
        peerRole: 'student',
      );
    }
  }

  void _initStream() {
    if (widget.sessionId.isNotEmpty && widget.sessionId != 'session-1') {
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

    if (widget.sessionId.isNotEmpty && widget.sessionId != 'session-1') {
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
      }).subscribe();
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

  @override
  void dispose() {
    _peerTypingTimer?.cancel();
    _debounceTypingTimer?.cancel();
    _sessionSubscription?.cancel();
    if (_statusChannel != null) {
      try {
        SupabaseService.client.removeChannel(_statusChannel!);
      } catch (_) {}
    }
    _focusNode.dispose();
    _textController.dispose();
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

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(counselorProvider.notifier).sendMessage(widget.sessionId, text);
    _textController.clear();
    _broadcastStatus('idle');

    _scrollToBottom(animated: true);
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Akhiri Sesi Konseling?',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Sesi konseling dengan mahasiswa ini akan ditandai selesai dan dicatat ke dalam metrik "Total Dibantu".',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.twilightDark,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.wisteriaNormal),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF88A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isEndingSession
                  ? null
                  : () async {
                      setState(() {
                        _isEndingSession = true;
                      });
                      Navigator.of(dialogContext).pop();
                      final success = await ref.read(counselorProvider.notifier).endSession(widget.sessionId);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Sesi konseling telah diselesaikan. Metrik terupdate!'
                                : 'Sesi konseling telah diselesaikan sebelumnya.'),
                          ),
                        );
                      }
                    },
              child: _isEndingSession
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Selesaikan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
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

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _copySelectedMessages(List<_CounselorViewMessage> messages) {
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

    ScaffoldMessenger.of(context).clearSnackBars();
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

  void _showDeleteOptionsModal(BuildContext context, List<_CounselorViewMessage> messages) {
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

  void _executeDeleteForMeMessages(List<_CounselorViewMessage> selected) {
    final selectedIds = selected.map((m) => m.id).toSet();
    setState(() {
      _deletedForMeLocalIds.addAll(selectedIds);
      final mutable = List<ChatMessageModel>.from(_cachedDbMessages);
      mutable.removeWhere((m) => selectedIds.contains(m.id));
      _cachedDbMessages = mutable;
      _selectedMessageIds.clear();
    });

    ref.read(counselingServiceProvider).updateSessionCache(widget.sessionId, _cachedDbMessages);

    final serverIds = selected
        .where((m) => m.id.isNotEmpty && !m.id.startsWith('fallback-') && !m.id.startsWith('demo-'))
        .map((m) => m.id)
        .toList();

    if (serverIds.isNotEmpty) {
      ref.read(counselingServiceProvider).deleteMessagesForMe(serverIds);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan berhasil dihapus untuk Anda'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _executeUnsendMessages(List<_CounselorViewMessage> selected) {
    final selectedIds = selected.map((m) => m.id).toSet();
    setState(() {
      _unsentLocalIds.addAll(selectedIds);
      final mutable = List<ChatMessageModel>.from(_cachedDbMessages);
      _cachedDbMessages = mutable.map((m) {
        if (selectedIds.contains(m.id)) {
          return m.copyWith(isDeletedForEveryone: true);
        }
        return m;
      }).toList();
      _selectedMessageIds.clear();
    });

    ref.read(counselingServiceProvider).updateSessionCache(widget.sessionId, _cachedDbMessages);

    final serverIds = selected
        .where((m) => m.id.isNotEmpty && !m.id.startsWith('fallback-') && !m.id.startsWith('demo-'))
        .map((m) => m.id)
        .toList();

    if (serverIds.isNotEmpty) {
      ref.read(counselingServiceProvider).unsendMessagesForEveryone(serverIds);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan berhasil ditarik'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counselorState = ref.watch(counselorProvider);
    final localMessages = counselorState.messages[widget.sessionId] ?? [];
    final currentUserId = SupabaseService.currentUserId;

    final List<_CounselorViewMessage> currentDisplayMessages = (_cachedDbMessages.isNotEmpty
            ? _cachedDbMessages
                .where((m) => !m.deletedForUsers.contains(currentUserId) && !_deletedForMeLocalIds.contains(m.id))
                .map((m) => _CounselorViewMessage(
                      id: m.id,
                      text: m.messageText,
                      isMe: m.senderId == currentUserId || m.senderRole == 'counselor',
                      time: m.createdAt.toLocal(),
                      deliveryStatus: m.isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
                      isDeletedForEveryone: m.isDeletedForEveryone || _unsentLocalIds.contains(m.id),
                    ))
            : localMessages
                .where((m) => !m.deletedForUsers.contains(currentUserId) && !_deletedForMeLocalIds.contains(m.id))
                .map((m) => _CounselorViewMessage(
                      id: m.id,
                      text: m.text,
                      isMe: m.isMe,
                      time: m.createdAt ?? DateTime.now(),
                      deliveryStatus: m.isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
                      isDeletedForEveryone: m.isDeletedForEveryone || _unsentLocalIds.contains(m.id),
                    )))
        .toList();

    return PopScope(
      canPop: !_showEmoji && _selectedMessageIds.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_showEmoji) {
          setState(() {
            _showEmoji = false;
          });
          _broadcastStatus('idle');
          return;
        }
        if (_selectedMessageIds.isNotEmpty) {
          _clearSelection();
          return;
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFDECEE),
                Color(0xFFF4F8FB),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 1. Custom App Bar Melengkung (Normal / Seleksi)
                _buildAppBar(context, currentDisplayMessages),

                // Offline Notice Banner
                if (!_isStreamConnected && _cachedDbMessages.isNotEmpty)
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

                // 2. Daftar Pesan Percakapan (Realtime stream with fallback)
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
                    child: widget.sessionId.isNotEmpty && widget.sessionId != 'session-1'
                        ? StreamBuilder<List<ChatMessageModel>>(
                            stream: _messagesStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                _cachedDbMessages = snapshot.data!;
                                _isStreamConnected = true;
                                ref.read(counselingServiceProvider).updateSessionCache(widget.sessionId, _cachedDbMessages);
                              } else if (snapshot.hasError) {
                                _isStreamConnected = false;
                              }

                              final activeDbMessages = _cachedDbMessages.isNotEmpty
                                  ? _cachedDbMessages
                                  : (snapshot.data ?? []);

                              final visibleMessages = activeDbMessages
                                  .where((m) => !m.deletedForUsers.contains(currentUserId) && !_deletedForMeLocalIds.contains(m.id))
                                  .toList();

                              if (visibleMessages.isEmpty) {
                                return _buildMessageListView(localMessages);
                              }

                              final mapped = visibleMessages.map((m) {
                                return _CounselorViewMessage(
                                  id: m.id,
                                  text: m.messageText,
                                  isMe: m.senderId == currentUserId || m.senderRole == 'counselor',
                                  time: m.createdAt.toLocal(),
                                  deliveryStatus: m.isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
                                  isDeletedForEveryone: m.isDeletedForEveryone || _unsentLocalIds.contains(m.id),
                                );
                              }).toList();

                              if (mapped.length != _lastMessageCount) {
                                _lastMessageCount = mapped.length;
                                _scrollToBottom(animated: true);
                                _markIncomingAsRead();
                              }

                              return _buildMappedMessageList(mapped);
                            },
                          )
                        : _buildMessageListView(localMessages),
                  ),
                ),

                // 3. Floating Input Bar or Completed Banner
                if (_isSessionCompleted)
                  _buildCompletedSessionBanner()
                else
                  _buildInputBar(),

                // 4. Papan Emoji Keyboard (Tampilan Sangat Rapi & Tema Soft Coral)
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
                          color: const Color(0xFFF88A8A).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: const Config(
                          height: 290,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
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
                            indicatorColor: Color(0xFFF88A8A),
                            iconColorSelected: Color(0xFFF88A8A),
                            iconColor: Colors.grey,
                            dividerColor: Color(0x1AF88A8A),
                            backspaceColor: Color(0xFFF88A8A),
                          ),
                          bottomActionBarConfig: BottomActionBarConfig(
                            enabled: true,
                            backgroundColor: Colors.white,
                            buttonColor: Color(0x20F88A8A),
                            buttonIconColor: Color(0xFFF88A8A),
                          ),
                          searchViewConfig: SearchViewConfig(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, List<_CounselorViewMessage> activeMessages) {
    if (_selectedMessageIds.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.twilightDarker),
              onPressed: _clearSelection,
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedMessageIds.length} dipilih',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.twilightDarker,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Salin Pesan',
              icon: const Icon(Icons.copy_rounded, color: AppColors.twilightDarker),
              onPressed: () => _copySelectedMessages(activeMessages),
            ),
            IconButton(
              tooltip: 'Hapus Pesan',
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.redNormal),
              onPressed: () => _showDeleteOptionsModal(context, activeMessages),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.twilightDarker),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),

          // Avatar dengan Online Badge
          const AnonymousAvatar(
            size: 40,
            isOnline: true,
            showBadge: true,
          ),
          const SizedBox(width: 12),

          // Judul Mahasiswa Anonim & Realtime Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _studentTitle,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                _buildStatusSubtitle(),
              ],
            ),
          ),

          // Menu Opsi Tiga Titik dengan Opsi Akhiri Sesi
          if (!_isSessionCompleted)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.twilightDarker),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'end_session') {
                  _showEndSessionDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'end_session',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Color(0xFFF88A8A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Selesaikan Sesi',
                        style: TextStyle(
                          color: Color(0xFFF88A8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStatusSubtitle() {
    if (_peerStatus == 'typing') {
      return const Text(
        'sedang mengetik...',
        style: TextStyle(
          color: Color(0xFFF88A8A),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      );
    }
    if (_peerStatus == 'choosing_emoji') {
      return const Text(
        'sedang memilih emoji... 😊',
        style: TextStyle(
          color: Color(0xFFF88A8A),
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
            color: Colors.greenAccent[700],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'Online',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.green[700],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageListView(List<CounselorChatMessage> messages) {
    final currentUserId = SupabaseService.currentUserId;
    final mapped = messages
        .where((m) => !m.deletedForUsers.contains(currentUserId) && !_deletedForMeLocalIds.contains(m.id))
        .map((m) {
      return _CounselorViewMessage(
        id: m.id,
        text: m.text,
        isMe: m.isMe,
        time: m.createdAt ?? DateTime.now(),
        deliveryStatus: m.isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
        isDeletedForEveryone: m.isDeletedForEveryone || _unsentLocalIds.contains(m.id),
      );
    }).toList();
    return _buildMappedMessageList(mapped);
  }

  Widget _buildMappedMessageList(List<_CounselorViewMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _buildMessageItem(messages[index]);
      },
    );
  }

  Widget _buildMessageItem(_CounselorViewMessage message) {
    final localTime = message.time.toLocal();
    final timeStr =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    final isSelected = _selectedMessageIds.contains(message.id);

    return GestureDetector(
      onLongPress: () => _toggleSelectMessage(message.id),
      onTap: () {
        if (_selectedMessageIds.isNotEmpty) {
          _toggleSelectMessage(message.id);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isSelected ? const Color(0xFFF88A8A).withValues(alpha: 0.12) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isMe) ...[
              if (_selectedMessageIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? const Color(0xFFF88A8A) : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              const AnonymousAvatar(
                size: 34,
                isOnline: false,
                showBadge: false,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 14, 8),
                decoration: BoxDecoration(
                  color: message.isDeletedForEveryone
                      ? Colors.grey.shade200
                      : (message.isMe ? const Color(0xFFF88A8A) : Colors.white),
                  border: isSelected
                      ? Border.all(color: const Color(0xFFF88A8A), width: 1.5)
                      : (message.isDeletedForEveryone
                          ? Border.all(color: Colors.grey.shade300)
                          : null),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                    bottomRight: Radius.circular(message.isMe ? 4 : 20),
                  ),
                  boxShadow: message.isDeletedForEveryone
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: message.isMe ? 0.05 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment:
                      message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.isDeletedForEveryone)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Pesan ini telah ditarik',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        message.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: message.isMe ? Colors.white : AppColors.twilightDarker,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: message.isDeletedForEveryone
                                ? Colors.grey.shade500
                                : (message.isMe ? Colors.white70 : AppColors.twilightNormal.withValues(alpha: 0.6)),
                            fontSize: 10,
                          ),
                        ),
                        if (message.isMe && !message.isDeletedForEveryone) ...[
                          const SizedBox(width: 4),
                          _buildDeliveryStatusIcon(message.deliveryStatus),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (message.isMe && _selectedMessageIds.isNotEmpty) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFFF88A8A) : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
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
          color: Colors.white,
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

  Widget _buildCompletedSessionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF88A8A).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFFF88A8A), size: 24),
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
              backgroundColor: const Color(0xFFF88A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildInputBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 8, 20, _showEmoji ? 8 : 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _showEmoji ? Icons.keyboard_outlined : Icons.sentiment_satisfied_alt_outlined,
              color: const Color(0xFFF88A8A),
              size: 26,
            ),
            onPressed: _toggleEmojiKeyboard,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1.5,
            height: 22,
            color: const Color(0xFFF88A8A).withValues(alpha: 0.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _textController,
              onChanged: (val) {
                _broadcastStatus(val.trim().isNotEmpty ? 'typing' : 'idle');
              },
              onSubmitted: (_) => _handleSend(),
              onTap: () {
                if (_showEmoji) {
                  setState(() {
                    _showEmoji = false;
                  });
                  _broadcastStatus('idle');
                }
                _scrollToBottom(animated: true);
              },
              decoration: const InputDecoration(
                hintText: 'Ketik pesan empati...',
                hintStyle: TextStyle(
                  color: AppColors.twilightLight,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFF88A8A),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: _handleSend,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounselorViewMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageDeliveryStatus deliveryStatus;
  final bool isDeletedForEveryone;

  _CounselorViewMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.isDeletedForEveryone = false,
  });

  _CounselorViewMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? time,
    MessageDeliveryStatus? deliveryStatus,
    bool? isDeletedForEveryone,
  }) {
    return _CounselorViewMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
    );
  }
}
