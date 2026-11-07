import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/core/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:curhat_finder/features/chat/presentation/providers/rooms_interaction_provider.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_radii.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/core/widgets/app_pill.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';

/// Widget Card Room Mandiri dengan Optimistic UI dan Animasi Pegas (Bounce)
class InteractiveRoomCard extends ConsumerStatefulWidget {
  final RoomModel room;
  final bool initialIsLiked;
  final bool initialIsBookmarked;
  final void Function(String roomId, bool newIsLiked) onToggleLike;
  final void Function(String roomId, bool newIsBookmarked) onToggleBookmark;
  final void Function(RoomModel updatedRoom) onTap;
  final bool isDetailHeader;
  final VoidCallback? onBackTap;
  final VoidCallback? onDeleted;

  const InteractiveRoomCard({
    super.key,
    required this.room,
    required this.initialIsLiked,
    required this.initialIsBookmarked,
    required this.onToggleLike,
    required this.onToggleBookmark,
    required this.onTap,
    this.isDetailHeader = false,
    this.onBackTap,
    this.onDeleted,
  });

  @override
  ConsumerState<InteractiveRoomCard> createState() => _InteractiveRoomCardState();
}

class _InteractiveRoomCardState extends ConsumerState<InteractiveRoomCard> with TickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  late AnimationController _bookmarkAnimController;
  late Animation<double> _bookmarkScaleAnim;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _likeAnimController.dispose();
    _bookmarkAnimController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    widget.onToggleLike(widget.room.id, !widget.initialIsLiked);
  }

  void _handleBookmarkTap() {
    _bookmarkAnimController.forward().then((_) => _bookmarkAnimController.reverse());
    widget.onToggleBookmark(widget.room.id, !widget.initialIsBookmarked);
  }

  void _showRoomOptions(BuildContext context) {
    final currentUserId = SupabaseService.currentUserId;
    final isOwner = widget.room.userId != null && widget.room.userId == currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.twilightLightActive,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                if (isOwner)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171)),
                    title: Text(
                      'Hapus Curhat',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFFF87171),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      final confirmed = await DeleteConfirmationDialog.show(
                        context,
                        title: 'Hapus Curhat Ini?',
                        message: 'Curhat yang sudah dihapus tidak dapat dipulihkan kembali. Apakah kamu yakin ingin menghapusnya?',
                      );
                      if (confirmed == true && mounted) {
                        try {
                          await ref.read(roomsInteractionProvider.notifier).deleteRoom(widget.room.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Curhat berhasil dihapus'),
                                backgroundColor: AppColors.twilightDarker,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            widget.onDeleted?.call();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus curhat: $e'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: AppColors.twilightDarker),
                  title: Text(
                    'Bagikan Curhat',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.twilightDarker),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tautan curhat disalin ke clipboard!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                if (!isOwner)
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: Color(0xFFF87171)),
                    title: Text(
                      'Laporkan Konten',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFFF87171),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Laporan Anda telah kami terima.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final isLiked = widget.initialIsLiked;
    final isBookmarked = widget.initialIsBookmarked;
    final likesCount = room.likesCount;

    return GestureDetector(
      onTap: widget.isDetailHeader
          ? null
          : () {
              widget.onTap(
                room.copyWith(
                  likesCount: likesCount,
                  isLiked: isLiked,
                  isBookmarked: isBookmarked,
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.borderLg,
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
                    if (widget.isDetailHeader && widget.onBackTap != null) ...[
                      GestureDetector(
                        onTap: widget.onBackTap,
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.twilightDarker,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    AppPill(
                      label: room.authorTag,
                      backgroundColor: AppColors.lavenderBlush,
                      textColor: AppColors.twilightDarker,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    const SizedBox(width: 8),
                    AppPill(
                      label: room.category,
                      backgroundColor: Colors.white,
                      textColor: AppColors.twilightDarker,
                      borderColor: AppColors.lavenderBlush,
                      borderWidth: 1.5,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showRoomOptions(context),
                  borderRadius: BorderRadius.circular(100),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_horiz,
                      color: AppColors.wisteriaNormalHover,
                    ),
                  ),
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
              maxLines: widget.isDetailHeader ? null : 4,
              overflow: widget.isDetailHeader ? TextOverflow.visible : TextOverflow.ellipsis,
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
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Text(
                                '$likesCount',
                                key: ValueKey<int>(likesCount),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                                  fontSize: 12,
                                  fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
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
                            color: AppColors.wisteriaDarkHover,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${room.commentsCount}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.wisteriaDarkHover,
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
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaDarkHover,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isBookmarked ? 'Tersimpan' : 'Simpan',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaDarkHover,
                            fontSize: 12,
                            fontWeight: isBookmarked ? FontWeight.bold : FontWeight.normal,
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
