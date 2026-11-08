import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Komponen Pill / Badge / Filter Chip dengan optical vertical centering presisi
/// Mengatasi ketidaksimetrisan ascender/descender font kustom (Gilroy) pada rounded capsule.
class AppPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double borderRadius;
  final Widget? leading;
  final Widget? trailing;

  const AppPill({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
    this.borderColor,
    this.selectedBorderColor,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize,
    this.fontWeight,
    this.borderRadius = 100,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = isSelected
        ? (selectedBackgroundColor ?? AppColors.lavenderBlush)
        : (backgroundColor ?? Colors.white);

    final effectiveBorderColor = isSelected
        ? (selectedBorderColor ?? AppColors.redNormalHover)
        : (borderColor ?? AppColors.twilightLight);

    final effectiveTextColor = isSelected
        ? (selectedTextColor ?? AppColors.twilightDarker)
        : (textColor ?? AppColors.twilightDark);

    final effectiveFontWeight = fontWeight ?? (isSelected ? FontWeight.w600 : FontWeight.w500);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                height: 1.0,
              ),
              style: AppTextStyles.labelMedium.copyWith(
                color: effectiveTextColor,
                fontSize: fontSize ?? 12,
                fontWeight: effectiveFontWeight,
                height: 1.0,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
