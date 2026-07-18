import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Disini tempat teman-teman ngatur style dan decoration text
/// Jadi yang di atur disini itu bakalan kepake di seluruh aplikasi
/// Supaya konsisten dan enak nantinya. Kalian ga bakalan ngatur style dan decoration manual lagi
/// Tapi kalo mau yang beda nantinya tinggal di timpa aja di style widget nya.
class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.inter(); // Ganti font disini

  // ini buat apa?

  // jadi _baseStyle itu cuma buat nyimpen font style nya aja
  // terus nanti tinggal di copyWith aja buat ngatur size, font weight, color nya

  // contoh: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.normal)
  // jadi nanti kalo mau pake tinggal gini:
  // Text('Hello', style: AppTextStyles.heading1)

  // ngerti kan ya? kalo belom coba search google search "flutter copyWith TextStyle"

  // template aja sih, mau buat sendiri gpp, tergantung Designer UI/UX kalian juga sih mau namanya apa
  
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
