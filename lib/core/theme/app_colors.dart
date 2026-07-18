import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama (Mode Terang)
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444); // Red 500

  // Warna Teks
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8); // Slate 400

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Catatan: Jika ingin menambahkan mode gelap di masa depan,
  // silakan definisikan token warna di bawah ini:
  // static const Color primaryDark = Color(0xFF1E293B);
  // static const Color backgroundDark = Color(0xFF0F172A);
  // static const Color surfaceDark = Color(0xFF1E293B);
}
