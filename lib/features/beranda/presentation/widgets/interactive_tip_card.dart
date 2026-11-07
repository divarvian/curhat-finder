import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/dialogs/delete_confirmation_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/tips_interaction_provider.dart';
import '../../domain/tip_model.dart';

/// Widget Card Mandiri untuk menampilkan Tip/Saran dengan Optimistic UI dan Spring Bounce Animation
class InteractiveTipCard extends ConsumerStatefulWidget {
  final TipModel item;
  final bool initialIsLiked;
  final bool initialIsBookmarked;
  final Future<bool> Function(String tipId) onToggleLike;
  final Future<bool> Function(String tipId) onToggleBookmark;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const InteractiveTipCard({
    super.key,
    required this.item,
    required this.initialIsLiked,
    required this.initialIsBookmarked,
    required this.onToggleLike,
    required this.onToggleBookmark,
    this.onTap,
    this.onDeleted,
  });

  @override
  ConsumerState<InteractiveTipCard> createState() => _InteractiveTipCardState();
}

class _InteractiveTipCardState extends ConsumerState<InteractiveTipCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

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
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    widget.onToggleLike(widget.item.id);
  }

  void _handleBookmarkTap() {
    widget.onToggleBookmark(widget.item.id);
  }

  void _showTipOptions(BuildContext context) {
    final currentUserId = SupabaseService.currentUserId;
    final isOwner = widget.item.userId != null && widget.item.userId == currentUserId;

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
                      'Hapus Tips',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFFF87171),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      final confirmed = await DeleteConfirmationDialog.show(
                        context,
                        title: 'Hapus Tips Ini?',
                        message: 'Tips yang sudah dihapus tidak dapat dipulihkan kembali. Apakah kamu yakin ingin menghapusnya?',
                      );
                      if (confirmed == true && mounted) {
                        try {
                          await ref.read(tipsInteractionProvider.notifier).deleteTip(widget.item.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tips berhasil dihapus'),
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
                                content: Text('Gagal menghapus tips: $e'),
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
                    'Bagikan Tips',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.twilightDarker),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tautan tips disalin ke clipboard!'),
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
    final item = widget.item;
    final isLiked = widget.initialIsLiked;
    final isBookmarked = widget.initialIsBookmarked;
    final likesCount = item.likesCount;

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
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
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderBlush,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${item.authorName} • ${item.authorFaculty} • ${item.category}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _showTipOptions(context),
                  borderRadius: BorderRadius.circular(100),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_horiz, color: AppColors.wisteriaNormal, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.displayTitle,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.displayDescription.isNotEmpty && item.displayDescription != item.displayTitle) ...[
              const SizedBox(height: 6),
              Text(
                item.displayDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightDarker.withValues(alpha: 0.85),
                  height: 1.45,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Suka / Like dengan animasi pegas
                InkWell(
                  onTap: _handleLikeTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _likeScaleAnim,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.redAccent : AppColors.wisteriaDarkHover,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: Text(
                            '$likesCount',
                            key: ValueKey<int>(likesCount),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isLiked ? Colors.redAccent : AppColors.wisteriaDarkHover,
                              fontSize: 12,
                              fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tombol Simpan / Bookmark
                InkWell(
                  onTap: _handleBookmarkTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaDarkHover,
                          size: 19,
                        ),
                        const SizedBox(width: 6),
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
