import 'package:flutter/material.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';

/// Widget Card Room Mandiri dengan Optimistic UI dan Animasi Pegas (Bounce)
class InteractiveRoomCard extends StatefulWidget {
  final RoomModel room;
  final bool initialIsLiked;
  final bool initialIsBookmarked;
  final void Function(String roomId, bool newIsLiked) onToggleLike;
  final void Function(String roomId, bool newIsBookmarked) onToggleBookmark;
  final void Function(RoomModel updatedRoom) onTap;

  const InteractiveRoomCard({
    super.key,
    required this.room,
    required this.initialIsLiked,
    required this.initialIsBookmarked,
    required this.onToggleLike,
    required this.onToggleBookmark,
    required this.onTap,
  });

  @override
  State<InteractiveRoomCard> createState() => _InteractiveRoomCardState();
}

class _InteractiveRoomCardState extends State<InteractiveRoomCard> with TickerProviderStateMixin {
  late int _likesCount;
  late bool _isLiked;
  late bool _isBookmarked;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  late AnimationController _bookmarkAnimController;
  late Animation<double> _bookmarkScaleAnim;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.room.likesCount;
    _isLiked = widget.initialIsLiked;
    _isBookmarked = widget.initialIsBookmarked;

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
  }

  @override
  void didUpdateWidget(covariant InteractiveRoomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.room.id != oldWidget.room.id) {
      _likesCount = widget.room.likesCount;
      _isLiked = widget.initialIsLiked;
      _isBookmarked = widget.initialIsBookmarked;
    } else {
      if (widget.initialIsLiked != oldWidget.initialIsLiked) {
        _isLiked = widget.initialIsLiked;
      }
      if (widget.initialIsBookmarked != oldWidget.initialIsBookmarked) {
        _isBookmarked = widget.initialIsBookmarked;
      }
      if (widget.room.likesCount != oldWidget.room.likesCount) {
        _likesCount = widget.room.likesCount;
      }
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    _bookmarkAnimController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    widget.onToggleLike(widget.room.id, _isLiked);
  }

  void _handleBookmarkTap() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    _bookmarkAnimController.forward().then((_) => _bookmarkAnimController.reverse());
    widget.onToggleBookmark(widget.room.id, _isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return GestureDetector(
      onTap: () {
        widget.onTap(
          room.copyWith(
            likesCount: _likesCount,
            isLiked: _isLiked,
            isBookmarked: _isBookmarked,
          ),
        );
      },
      child: Container(
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
            // Header (Tags & More Options)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderBlush,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        room.authorTag,
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
                        room.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.more_horiz,
                  color: AppColors.wisteriaNormalHover,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            if (room.title.isNotEmpty) ...[
              Text(
                room.title,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              room.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Footer (Likes with Spring Bounce, Comments, Bookmark with Spring Bounce)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Tombol Suka / Like dengan animasi pegas
                    InkWell(
                      onTap: _handleLikeTap,
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
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Text(
                                '$_likesCount',
                                key: ValueKey<int>(_likesCount),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                                  fontSize: 12,
                                  fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Komentar Counter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.wisteriaNormalHover,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${room.commentsCount}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.wisteriaNormalHover,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tombol Bookmark / Simpan dengan animasi pegas
                InkWell(
                  onTap: _handleBookmarkTap,
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
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isBookmarked ? 'Tersimpan' : 'Simpan',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaNormalHover,
                            fontSize: 12,
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
    );
  }
}
