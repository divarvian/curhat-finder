import 'package:flutter/material.dart';

class AppColors {
  // Wisteria Blue Scale (Secondary/Accent)
  static const Color wisteriaLight = Color(0xFFf2f4fa);
  static const Color wisteriaLightHover = Color(0xFFebeff8);
  static const Color wisteriaLightActive = Color(0xFFd6def0);
  static const Color wisteriaNormal = Color(0xFF7b95cf);
  static const Color wisteriaNormalHover = Color(0xFF6f86ba);
  static const Color wisteriaNormalActive = Color(0xFF6277a6);
  static const Color wisteriaDark = Color(0xFF5c709b);
  static const Color wisteriaDarkHover = Color(0xFF4a597c);
  static const Color wisteriaDarkActive = Color(0xFF37435d);
  static const Color wisteriaDarker = Color(0xFF2b3448);

  // Twilight Indigo Scale (Primary/Header)
  static const Color twilightLight = Color(0xFFeaecf0);
  static const Color twilightLightHover = Color(0xFFe0e3e9);
  static const Color twilightLightActive = Color(0xFFbfc5d1);
  static const Color twilightNormal = Color(0xFF304369);
  static const Color twilightNormalHover = Color(0xFF2b3c5f);
  static const Color twilightNormalActive = Color(0xFF263654);
  static const Color twilightDark = Color(0xFF24324f);
  static const Color twilightDarkHover = Color(0xFF1d283f);
  static const Color twilightDarkActive = Color(0xFF161e2f);
  static const Color twilightDarker = Color(0xFF111725);

  // Cotton Rose Scale (Error/Warning/Red Accent)
  static const Color redLight = Color(0xFFfefafa);
  static const Color redLightHover = Color(0xFFfef8f8);
  static const Color redLightActive = Color(0xFFfdf0f0);
  static const Color redNormal = Color(0xFFf8d0d0);
  static const Color redNormalHover = Color(0xFFdfbbbb);
  static const Color redNormalActive = Color(0xFFc6a6a6);
  static const Color redDark = Color(0xFFba9c9c);
  static const Color redDarkHover = Color(0xFF957d7d);
  static const Color redDarkActive = Color(0xFF705e5e);
  static const Color redDarker = Color(0xFF574949);

  // Additional Base Colors
  static const Color platinum = Color(0xFFF4F8FB);
  static const Color lavender = Color(0xFFDEE5F3);
  static const Color lavenderBlush = Color(0xFFFCEDED);
  static const Color sunshineYellow = Color(0xFFFFD54F);

  // Semantic Colors
  static const Color primary = twilightNormal;
  static const Color secondary = wisteriaNormal;
  static const Color background = platinum;
  static const Color surface = Colors.white;
  static const Color error = redDarkHover; // Using darker shade for readability

  // Text Colors
  static const Color textPrimary = twilightDarker;
  static const Color textSecondary = wisteriaDark;
  static const Color textLight = wisteriaNormal;

  // Border & Divider
  static const Color border = wisteriaLightActive;
}
