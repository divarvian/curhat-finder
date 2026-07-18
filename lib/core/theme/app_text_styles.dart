import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.inter();

  static TextStyle get heading1 => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading2 => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading3 => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textLight,
      );
}
