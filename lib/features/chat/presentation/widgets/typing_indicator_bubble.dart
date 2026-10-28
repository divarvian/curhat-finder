import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TypingIndicatorBubble extends StatefulWidget {
  final String peerName;
  final String status; // 'typing' or 'choosing_emoji'
  final Color? accentColor;

  const TypingIndicatorBubble({
    super.key,
    required this.peerName,
    required this.status,
    this.accentColor,
  });

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.accentColor ?? AppColors.wisteriaNormal;
    final isEmoji = widget.status == 'choosing_emoji';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEmoji) ...[
            const Text(
              '😊',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
          ] else ...[
            // 3 Animated Bouncing Dots
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final progress = (_animController.value - delay) % 1.0;
                    final bounce = (progress < 0.5)
                        ? (progress * 2)
                        : ((1.0 - progress) * 2);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 5.5,
                      height: 5.5 + (bounce * 3.5),
                      decoration: BoxDecoration(
                        color: effectiveColor.withValues(alpha: 0.5 + (bounce * 0.5)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              isEmoji
                  ? '${widget.peerName} sedang memilih emoji...'
                  : '${widget.peerName} sedang mengetik...',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.twilightDarker,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
