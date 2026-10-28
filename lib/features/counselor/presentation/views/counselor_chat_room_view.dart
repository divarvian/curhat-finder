import 'dart:async';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _studentTitle = widget.studentTitle;
    _cachedDbMessages = ref.read(counselingServiceProvider).getSessionCache(widget.sessionId);
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
      _cachedDbMessages = ref.read(counselingServiceProvider).getSessionCache(widget.sessionId);
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

  @override
  Widget build(BuildContext context) {
    final counselorState = ref.watch(counselorProvider);
    final localMessages = counselorState.messages[widget.sessionId] ?? [];
    final currentUserId = SupabaseService.currentUserId;

    return PopScope(
      canPop: !_showEmoji,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showEmoji) {
          setState(() {
            _showEmoji = false;
          });
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
                // 1. Custom App Bar Melengkung
                _buildAppBar(context),

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

                              if (activeDbMessages.isEmpty) {
                                return _buildMessageListView(localMessages);
                              }

                              final mapped = activeDbMessages.map((m) {
                                return _CounselorViewMessage(
                                  text: m.messageText,
                                  isMe: m.senderId == currentUserId || m.senderRole == 'counselor',
                                  time: m.createdAt.toLocal(),
                                  deliveryStatus: m.isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
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

  Widget _buildAppBar(BuildContext context) {
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
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(
          text: message.text,
          isMe: message.isMe,
          time: DateTime.now(),
          deliveryStatus: MessageDeliveryStatus.sent,
        );
      },
    );
  }

  Widget _buildMappedMessageList(List<_CounselorViewMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(
          text: message.text,
          isMe: message.isMe,
          time: message.time,
          deliveryStatus: message.deliveryStatus,
        );
      },
    );
  }

  Widget _buildMessageItem({
    required String text,
    required bool isMe,
    required DateTime time,
    required MessageDeliveryStatus deliveryStatus,
  }) {
    final localTime = time.toLocal();
    final timeStr =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    if (isMe) {
      // Bubble Konselor (Outgoing) - Soft Coral
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 14, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF88A8A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildDeliveryStatusIcon(deliveryStatus),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Bubble Mahasiswa Anonim (Incoming) - Putih dengan Avatar
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const AnonymousAvatar(
              size: 34,
              isOnline: false,
              showBadge: false,
            ),
            const SizedBox(width: 10),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 14, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.twilightNormal.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
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
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageDeliveryStatus deliveryStatus;

  _CounselorViewMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });
}
