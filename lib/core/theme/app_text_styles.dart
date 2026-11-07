import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Disini tempat teman-teman mengatur gaya tulisan (font) aplikasi nya
/// Jadi yang teman-teman atur disini itu bakalan dipake di seluruh aplikasi
/// Supaya konsisten dan enak nantinya. Kalian ga bakalan ngatur style dan decoration manual lagi
/// Tapi kalo mau yang beda nantinya tinggal di timpa aja di style widget nya.
class AppTextStyles {
  // Base style explicitly defines font family, size, accessible letterSpacing, line height, and color
  static TextStyle _baseStyle({
    required double size,
    required String family,
    required Color color,
    double letterSpacing = 0.0,
    double height = 1.3,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // 45px - Display Large
  static TextStyle get displayLarge => _baseStyle(
        size: 45,
        family: 'Gilroy-Heavy',
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.15,
      );
  
  // 40px - Display Medium
  static TextStyle get displayMedium => _baseStyle(
        size: 40,
        family: 'Gilroy-Heavy',
        color: AppColors.textPrimary,
        letterSpacing: -0.15,
        height: 1.2,
      );
  
  // 35px - Display Small
  static TextStyle get displaySmall => _baseStyle(
        size: 35,
        family: 'Gilroy-Bold',
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.25,
      );

  // 32px - Heading 1
  static TextStyle get heading1 => _baseStyle(
        size: 32,
        family: 'Gilroy-Bold',
        color: AppColors.textPrimary,
        letterSpacing: 0.0,
        height: 1.25,
      );

  // 28px - Heading 2
  static TextStyle get heading2 => _baseStyle(
        size: 28,
        family: 'Gilroy-Bold',
        color: AppColors.textPrimary,
        letterSpacing: 0.0,
        height: 1.3,
      );

  // 24px - Heading 3
  static TextStyle get heading3 => _baseStyle(
        size: 24,
        family: 'Gilroy-Medium',
        color: AppColors.textPrimary,
        letterSpacing: 0.05,
        height: 1.3,
      );

  // 20px - Title Large
  static TextStyle get titleLarge => _baseStyle(
        size: 20,
        family: 'Gilroy-Medium',
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.35,
      );

  // 15px - Body Large (Accessible & Dyslexia-Friendly)
  static TextStyle get bodyLarge => _baseStyle(
        size: 15,
        family: 'Gilroy-Regular',
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
        height: 1.5,
      );

  // 14px - Body Medium (Accessible & Dyslexia-Friendly)
  static TextStyle get bodyMedium => _baseStyle(
        size: 14,
        family: 'Gilroy-Regular',
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
        height: 1.5,
      );

  // 12px - Body Small (Accessible & Dyslexia-Friendly)
  static TextStyle get bodySmall => _baseStyle(
        size: 12,
        family: 'Gilroy-Regular',
        color: AppColors.textSecondary,
        letterSpacing: 0.25,
        height: 1.45,
      );

  // 15px - Label Large
  static TextStyle get labelLarge => _baseStyle(
        size: 15,
        family: 'Gilroy-Bold',
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
        height: 1.3,
      );
  
  // 12px - Label Medium
  static TextStyle get labelMedium => _baseStyle(
        size: 12,
        family: 'Gilroy-Medium',
        color: AppColors.textLight,
        letterSpacing: 0.2,
        height: 1.3,
      );
  
  // 11px - Label Small
  static TextStyle get labelSmall => _baseStyle(
        size: 11,
        family: 'Gilroy-Medium',
        color: AppColors.textLight,
        letterSpacing: 0.25,
        height: 1.3,
      );
}
