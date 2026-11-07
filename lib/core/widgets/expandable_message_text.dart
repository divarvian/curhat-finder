import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget pembungkus teks gelembung chat dengan dukungan pemotongan teks panjang
/// dan tombol interaktif "Baca selengkapnya" / "Tampilkan lebih sedikit".
class ExpandableMessageText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool isMe;
  final int cutoffLength;

  const ExpandableMessageText({
    super.key,
    required this.text,
    required this.style,
    required this.isMe,
    this.cutoffLength = 360,
  });

  @override
  State<ExpandableMessageText> createState() => _ExpandableMessageTextState();
}

class _ExpandableMessageTextState extends State<ExpandableMessageText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final isLong = text.length > widget.cutoffLength;

    if (!isLong) {
      return Text(text, style: widget.style);
    }

    final displayText = _isExpanded
        ? text
        : '${text.substring(0, widget.cutoffLength).trimRight()}...';

    final actionColor = widget.isMe
        ? Colors.white.withValues(alpha: 0.88)
        : AppColors.wisteriaNormalActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topLeft,
          child: Text(
            displayText,
            style: widget.style,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya',
                  style: widget.style.copyWith(
                    fontSize: (widget.style.fontSize ?? 14) * 0.88,
                    fontWeight: FontWeight.w700,
                    color: actionColor,
                    decoration: TextDecoration.underline,
                    decorationColor: actionColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: actionColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
