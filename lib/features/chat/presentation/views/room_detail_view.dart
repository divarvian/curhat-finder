import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/dialogs/delete_confirmation_dialog.dart';
import '../../data/room_service.dart';
import '../../domain/room_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../counselor/presentation/providers/counselor_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/rooms_interaction_provider.dart';
import '../widgets/cards/interactive_room_card.dart';

class RoomDetailView extends ConsumerStatefulWidget {
  final String roomId;
  final RoomModel? room;

  const RoomDetailView({
    super.key,
    this.roomId = '',
    this.room,
  });

  @override
  ConsumerState<RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends ConsumerState<RoomDetailView> {
  RoomModel? _room;
  bool _isLiked = false;
  bool _isBookmarked = false;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentHeaderKey = GlobalKey();
  bool _isSubmitting = false;

  Stream<List<RoomCommentModel>>? _commentsStream;
  String? _cachedRoomId;
  final List<RoomCommentModel> _optimisticComments = [];
  final Set<String> _deletedCommentIds = {};

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _isLiked = widget.room?.isLiked ?? false;
    _isBookmarked = widget.room?.isBookmarked ?? false;

    _loadRoomData();
    _initCommentsStream();
  }

  void _initCommentsStream() {
    final targetId = _room?.id ?? widget.roomId;
    if (targetId.isNotEmpty && targetId != _cachedRoomId) {
      _cachedRoomId = targetId;
      _commentsStream = ref.read(roomServiceProvider).streamComments(targetId);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRoomData() async {
    final roomService = ref.read(roomServiceProvider);
    final targetId = _room?.id ?? widget.roomId;

    if (_room == null && targetId.isNotEmpty) {
      final fetched = await roomService.getRoom(targetId);
      if (mounted && fetched != null) {
        setState(() {
          _room = fetched;
          _initCommentsStream();
        });
      }
    }
  }

  void _handleBack() {
    final effectiveId = _room?.id ?? widget.roomId;
    final roomInteraction = ref.read(roomsInteractionProvider);
    final roomNotifier = ref.read(roomsInteractionProvider.notifier);
    final isLiked = roomInteraction.likedRoomIds.contains(effectiveId);
    final isBookmarked = roomInteraction.bookmarkedRoomIds.contains(effectiveId);
    final likesCount = _room != null ? roomNotifier.getEffectiveLikesCount(effectiveId, _room!.likesCount) : (_room?.likesCount ?? 0);

    Navigator.pop(context, {
      'roomId': effectiveId,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'likesCount': likesCount,
      'commentsCount': _room?.commentsCount ?? 0,
    });
  }

  void _toggleLike() {
    final targetId = _room?.id ?? widget.roomId;
    if (targetId.isEmpty) return;
    ref.read(roomsInteractionProvider.notifier).toggleLike(targetId);
  }

  void _toggleBookmark() {
    final targetId = _room?.id ?? widget.roomId;
    if (targetId.isEmpty) return;
    ref.read(roomsInteractionProvider.notifier).toggleBookmark(targetId);
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    final targetId = _room?.id ?? widget.roomId;
    if (text.isEmpty || targetId.isEmpty || _isSubmitting) return;

    _isSubmitting = true;
    final auth = ref.read(authProvider);
    final String authorName;
    final String authorFaculty;
    final String authorRole;
    final String? authorAvatarUrl;

    if (auth.role == 'konselor') {
      final counselor = ref.read(counselorProvider).profile;
      authorRole = 'konselor';
      authorName = counselor.name.isNotEmpty && counselor.name != 'Konselor'
          ? counselor.name
          : (auth.username ?? 'Konselor Sebaya');
      authorFaculty = counselor.faculty.isNotEmpty
          ? (counselor.faculty.contains('(')
              ? counselor.faculty.split('(').last.replaceAll(')', '').trim()
              : counselor.faculty.split(' ').first)
          : 'FILKOM';
      authorAvatarUrl = counselor.avatarUrl;
    } else {
      final profile = ref.read(profileProvider);
      final facultyTag = profile.faculty.contains('(')
          ? profile.faculty.split('(').last.replaceAll(')', '').trim()
          : (profile.faculty.isNotEmpty ? profile.faculty.split(' ').first : 'UB');
      authorName = profile.name.isNotEmpty ? profile.name : 'Anonim';
      authorFaculty = facultyTag;
      authorRole = profile.role.isNotEmpty ? profile.role : 'mahasiswa';
      authorAvatarUrl = profile.avatarUrl;
    }

    FocusScope.of(context).unfocus();
    _commentController.clear();

    final currentUserId = SupabaseService.currentUserId;
    final optimisticComment = RoomCommentModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: targetId,
      userId: currentUserId,
      authorName: authorName,
      authorFaculty: authorFaculty,
      authorRole: authorRole,
      authorAvatarUrl: authorAvatarUrl,
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _optimisticComments.insert(0, optimisticComment);
      if (_room != null) {
        _room = _room!.copyWith(commentsCount: _room!.commentsCount + 1);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_commentHeaderKey.currentContext != null) {
        Scrollable.ensureVisible(
          _commentHeaderKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    try {
      final createdComment = await ref.read(roomServiceProvider).addComment(
        roomId: targetId,
        content: text,
        authorName: authorName,
        authorFaculty: authorFaculty,
        authorRole: authorRole,
        authorAvatarUrl: authorAvatarUrl,
      );
      if (createdComment != null && mounted) {
        setState(() {
          final idx = _optimisticComments.indexWhere((c) => c.id == optimisticComment.id);
          if (idx != -1) {
            _optimisticComments[idx] = createdComment;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _optimisticComments.removeWhere((c) => c.id == optimisticComment.id);
          if (_room != null) {
            _room = _room!.copyWith(
              commentsCount: (_room!.commentsCount - 1).clamp(0, 999999),
            );
          }
          _commentController.text = text;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal mengirim balasan. Draf telah dikembalikan.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _submitComment,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleDeleteComment(RoomCommentModel comment) async {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();

    final confirm = await DeleteConfirmationDialog.show(
      context,
      title: 'Hapus Komentar?',
      message: 'Apakah kamu yakin ingin menghapus komentar ini? Tindakan ini tidak dapat dibatalkan.',
    );

    if (confirm == true) {
      setState(() {
        _deletedCommentIds.add(comment.id);
        _optimisticComments.removeWhere((c) => c.id == comment.id);
        if (_room != null) {
          _room = _room!.copyWith(
            commentsCount: (_room!.commentsCount - 1).clamp(0, 999999),
          );
        }
      });

      final success = await ref.read(roomServiceProvider).deleteComment(comment.id);
      if (!success && mounted) {
        setState(() {
          _deletedCommentIds.remove(comment.id);
          if (_room != null) {
            _room = _room!.copyWith(
              commentsCount: _room!.commentsCount + 1,
            );
          }
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus komentar dari server. Silakan coba lagi.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 2) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentRoom = _room;
    final effectiveId = currentRoom?.id ?? widget.roomId;

    final roomInteraction = ref.watch(roomsInteractionProvider);
    final roomNotifier = ref.read(roomsInteractionProvider.notifier);

    final isLiked = effectiveId.isNotEmpty
        ? roomInteraction.likedRoomIds.contains(effectiveId)
        : _isLiked;
    final isBookmarked = effectiveId.isNotEmpty
        ? roomInteraction.bookmarkedRoomIds.contains(effectiveId)
        : _isBookmarked;
    final likesCount = currentRoom != null
        ? roomNotifier.getEffectiveLikesCount(effectiveId, currentRoom.likesCount)
        : (currentRoom?.likesCount ?? 0);

    final isCounselor = ref.watch(authProvider).role == 'konselor';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isCounselor
                  ? const [
                      AppColors.counselorChatGradientTop,
                      AppColors.counselorChatGradientBottom,
                    ]
                  : const [
                      AppColors.jurnalGradientTop,
                      AppColors.jurnalGradientBottom,
                    ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
            children: [
              // Konten Detail & Komentar
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // Post Card Utama (Dikonsolidasikan via InteractiveRoomCard)
                    if (currentRoom != null)
                      InteractiveRoomCard(
                        room: currentRoom.copyWith(likesCount: likesCount),
                        isDetailHeader: true,
                        onBackTap: _handleBack,
                        initialIsLiked: isLiked,
                        initialIsBookmarked: isBookmarked,
                        onToggleLike: (id, val) => _toggleLike(),
                        onToggleBookmark: (id, val) => _toggleBookmark(),
                        onTap: (_) {},
                        onDeleted: () => Navigator.pop(context),
                      )
                    else
                      const RoomCardSkeleton(),
                  const SizedBox(height: 24),

                  // Header Komentar
                  Text(
                    'Komentar & Dukungan',
                    key: _commentHeaderKey,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Realtime Daftar Komentar dengan Cached Stream & Optimistic Updates
                  if (effectiveId.isNotEmpty)
                    StreamBuilder<List<RoomCommentModel>>(
                      stream: _commentsStream,
                      builder: (context, snapshot) {
                        final serverComments = snapshot.data ?? [];
                        final displayComments = serverComments
                            .where((c) => !_deletedCommentIds.contains(c.id))
                            .toList();
                        for (final opt in _optimisticComments) {
                          final alreadyInServer = displayComments.any((sc) =>
                            sc.id == opt.id || (sc.content == opt.content && sc.authorTag == opt.authorTag)
                          );
                          if (!alreadyInServer && !_deletedCommentIds.contains(opt.id)) {
                            displayComments.add(opt);
                          }
                        }
                        // Pastikan komentar terurut: yang terbaru selalu di paling atas
                        displayComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                        if ((snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) && displayComments.isEmpty) {
                          return const Column(
                            children: [
                              CommentCardSkeleton(),
                              CommentCardSkeleton(),
                            ],
                          );
                        }

                        if (displayComments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Belum ada balasan. Tulis dukunganmu untuk teman kampus di bawah!',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.twilightNormal.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: displayComments.map((comment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCommentCard(comment),
                            );
                          }).toList(),
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Comment Input Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.platinum,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: ref.watch(authProvider).role == 'konselor'
                                  ? 'Tulis tanggapan atau bimbingan konselor...'
                                  : 'Tulis balasan atau kata semangat...',
                              hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.twilightNormal.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (_) => _submitComment(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.twilightDarker,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: _isSubmitting ? null : _submitComment,
                        ),
                      ),
                    ],
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

  Widget _buildCommentCard(RoomCommentModel comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          AppAvatar(
            imageUrl: comment.authorAvatarUrl,
            size: 36,
          ),
          const SizedBox(width: 12),
          
          // Konten Komentar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              comment.authorName,
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (comment.isCounselor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.lavenderBlush,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, size: 12, color: AppColors.wisteriaNormal),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Konselor Sebaya',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.twilightNormal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Flexible(
                              child: Text(
                                ' • ${comment.authorFaculty}',
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimeAgo(comment.createdAt),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        if (comment.userId != null &&
                            SupabaseService.currentUserId != null &&
                            comment.userId == SupabaseService.currentUserId) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _handleDeleteComment(comment),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: AppColors.redNormal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightDark,
                    fontSize: 13,
                    height: 1.4,
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
