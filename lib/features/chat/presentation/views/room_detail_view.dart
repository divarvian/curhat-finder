import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/room_service.dart';
import '../../domain/room_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

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

class _RoomDetailViewState extends ConsumerState<RoomDetailView> with TickerProviderStateMixin {
  RoomModel? _room;
  bool _isLiked = false;
  bool _isBookmarked = false;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;
  late AnimationController _bookmarkAnimController;
  late Animation<double> _bookmarkScaleAnim;

  Stream<List<RoomCommentModel>>? _commentsStream;
  String? _cachedRoomId;
  final List<RoomCommentModel> _optimisticComments = [];

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _isLiked = widget.room?.isLiked ?? false;
    _isBookmarked = widget.room?.isBookmarked ?? false;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _likeScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeAnimController, curve: Curves.easeOutBack),
    );

    _bookmarkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _bookmarkScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _bookmarkAnimController, curve: Curves.easeOutBack),
    );

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
    _likeAnimController.dispose();
    _bookmarkAnimController.dispose();
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

    if (targetId.isNotEmpty) {
      try {
        final likes = await roomService.fetchUserRoomLikes();
        final bookmarks = await roomService.fetchUserRoomBookmarks();
        if (mounted) {
          setState(() {
            if (likes.contains(targetId)) {
              _isLiked = true;
            }
            if (bookmarks.contains(targetId)) {
              _isBookmarked = true;
            }
          });
        }
      } catch (_) {}
    }
  }

  void _handleBack() {
    final effectiveId = _room?.id ?? widget.roomId;
    Navigator.pop(context, {
      'roomId': effectiveId,
      'isLiked': _isLiked,
      'isBookmarked': _isBookmarked,
      'likesCount': _room?.likesCount ?? 0,
      'commentsCount': _room?.commentsCount ?? 0,
    });
  }

  void _toggleLike() async {
    final targetId = _room?.id ?? widget.roomId;
    if (targetId.isEmpty) return;

    setState(() {
      _isLiked = !_isLiked;
      if (_room != null) {
        _room = _room!.copyWith(
          likesCount: _isLiked ? _room!.likesCount + 1 : (_room!.likesCount - 1).clamp(0, 99999),
        );
      }
    });

    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    await ref.read(roomServiceProvider).toggleLikeRoom(targetId);
  }

  void _toggleBookmark() async {
    final targetId = _room?.id ?? widget.roomId;
    if (targetId.isEmpty) return;

    setState(() {
      _isBookmarked = !_isBookmarked;
      if (_room != null) {
        _room = _room!.copyWith(
          bookmarksCount: _isBookmarked ? _room!.bookmarksCount + 1 : (_room!.bookmarksCount - 1).clamp(0, 99999),
        );
      }
    });

    _bookmarkAnimController.forward().then((_) => _bookmarkAnimController.reverse());
    await ref.read(roomServiceProvider).toggleBookmarkRoom(targetId);
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    final targetId = _room?.id ?? widget.roomId;
    if (text.isEmpty || targetId.isEmpty || _isSubmitting) return;

    _isSubmitting = true;
    final profile = ref.read(profileProvider);
    final facultyTag = profile.faculty.contains('(')
        ? profile.faculty.split('(').last.replaceAll(')', '').trim()
        : (profile.faculty.isNotEmpty ? profile.faculty.split(' ').first : 'UB');
    final authorTag = '${profile.gender.isNotEmpty ? profile.gender : "Mahasiswa"} • $facultyTag';

    _commentController.clear();

    final optimisticComment = RoomCommentModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: targetId,
      authorTag: authorTag,
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _optimisticComments.add(optimisticComment);
      if (_room != null) {
        _room = _room!.copyWith(commentsCount: _room!.commentsCount + 1);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    try {
      await ref.read(roomServiceProvider).addComment(
        roomId: targetId,
        content: text,
        authorTag: authorTag,
      );
    } catch (_) {
    } finally {
      _isSubmitting = false;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.platinum,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Konten Detail & Komentar
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // Post Card Utama
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Bar / Header Post
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _handleBack,
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.twilightDarker,
                                ),
                              ),
                              const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.lavenderBlush,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                currentRoom?.authorTag ?? 'Anonim • FILKOM',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.twilightDarker,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.lavenderBlush, width: 1.5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                currentRoom?.category ?? 'Umum',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.twilightDarker,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentRoom != null ? _formatTimeAgo(currentRoom.createdAt) : 'Hari ini',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.more_horiz,
                              color: AppColors.wisteriaNormalHover,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Title
                        if (currentRoom != null && currentRoom.title.isNotEmpty) ...[
                          Text(
                            currentRoom.title,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.twilightDarker,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Body Text
                        Text(
                          currentRoom?.content ?? 'Memuat curhatan...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.twilightDark,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer Post Utama (with Spring Bounce and Smooth Counters)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: _toggleLike,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    child: Row(
                                      children: [
                                        ScaleTransition(
                                          scale: _likeScaleAnim,
                                          child: Icon(
                                            _isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: _isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 150),
                                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                          child: Text(
                                            '${currentRoom?.likesCount ?? 0}',
                                            key: ValueKey<int>(currentRoom?.likesCount ?? 0),
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: _isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                                              fontSize: 13,
                                              fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: AppColors.wisteriaNormalHover,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${currentRoom?.commentsCount ?? 0}',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.wisteriaNormalHover,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _toggleBookmark,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Row(
                                  children: [
                                    ScaleTransition(
                                      scale: _bookmarkScaleAnim,
                                      child: Icon(
                                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                        color: _isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaNormalHover,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isBookmarked ? 'Tersimpan' : 'Simpan',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: _isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaNormalHover,
                                        fontSize: 13,
                                        fontWeight: _isBookmarked ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header Komentar
                  Text(
                    'Komentar & Dukungan',
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
                        final displayComments = <RoomCommentModel>[...serverComments];
                        for (final opt in _optimisticComments) {
                          final alreadyInServer = serverComments.any((sc) =>
                            sc.content == opt.content && sc.authorTag == opt.authorTag
                          );
                          if (!alreadyInServer) {
                            displayComments.add(opt);
                          }
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

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Bottom Comment Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                          hintText: 'Tulis balasan atau kata semangat...',
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
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _submitComment,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          Container(
            width: 36,
            height: 36,
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
          const SizedBox(width: 12),
          
          // Konten Komentar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.authorTag,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.twilightDarker,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
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
