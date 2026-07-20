import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Disini tempat teman-teman mengatur gaya tulisan (font) aplikasi nya
/// Jadi yang teman-teman atur disini itu bakalan dipake di seluruh aplikasi
/// Supaya konsisten dan enak nantinya. Kalian ga bakalan ngatur style dan decoration manual lagi
/// Tapi kalo mau yang beda nantinya tinggal di timpa aja di style widget nya.
class AppTextStyles {
  // Base style now explicitly takes the font family name
  static TextStyle _baseStyle(double size, String family, Color color) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      color: color,
      letterSpacing: size * -0.05, // -5% letter spacing
    );
  }

  // 45px
  static TextStyle get displayLarge => _baseStyle(45, 'Gilroy-Heavy', AppColors.textPrimary);
  
  // 40px
  static TextStyle get displayMedium => _baseStyle(40, 'Gilroy-Heavy', AppColors.textPrimary);
  
  // 35px
  static TextStyle get displaySmall => _baseStyle(35, 'Gilroy-Bold', AppColors.textPrimary);

  // 32px
  static TextStyle get heading1 => _baseStyle(32, 'Gilroy-Bold', AppColors.textPrimary);

  // 28px
  static TextStyle get heading2 => _baseStyle(28, 'Gilroy-Bold', AppColors.textPrimary);

  // 24px
  static TextStyle get heading3 => _baseStyle(24, 'Gilroy-Medium', AppColors.textPrimary);

  // 20px
  static TextStyle get titleLarge => _baseStyle(20, 'Gilroy-Medium', AppColors.textPrimary);

  // 15px
  static TextStyle get bodyLarge => _baseStyle(15, 'Gilroy-Regular', AppColors.textSecondary);

  // 12px
  static TextStyle get bodySmall => _baseStyle(12, 'Gilroy-Regular', AppColors.textSecondary);

  // 14px (Ditambahkan agar tidak error di halaman yang sudah ada)
  static TextStyle get bodyMedium => _baseStyle(14, 'Gilroy-Regular', AppColors.textSecondary);

  // Custom weights for buttons/labels
  static TextStyle get labelLarge => _baseStyle(15, 'Gilroy-Bold', AppColors.textPrimary);
  
  // 12px (Ditambahkan agar tidak error di TextField)
  static TextStyle get labelMedium => _baseStyle(12, 'Gilroy-Medium', AppColors.textLight);
  
  static TextStyle get labelSmall => _baseStyle(12, 'Gilroy-Medium', AppColors.textLight);
}
