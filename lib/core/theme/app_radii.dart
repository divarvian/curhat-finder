import 'package:flutter/material.dart';

/// Semantic border radius design tokens for Curhat Finder.
/// Standardizes component curvature across cards, dialogs, buttons, and inputs.
class AppRadii {
  AppRadii._();

  /// Radius 4px: Digunakan khusus untuk sudut mikro / ekor bubble chat
  static const double xs = 4.0;
  static const Radius radiusXs = Radius.circular(xs);
  static const BorderRadius borderXs = BorderRadius.all(radiusXs);

  /// Radius 12px: Form input fields, tag chips, dropdowns, secondary action buttons
  static const double sm = 12.0;
  static const Radius radiusSm = Radius.circular(sm);
  static const BorderRadius borderSm = BorderRadius.all(radiusSm);

  /// Radius 16px: Tombol standar, dialog konfirmasi, snackbars, notification banners
  static const double md = 16.0;
  static const Radius radiusMd = Radius.circular(md);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);

  /// Radius 24px: Kartu konten utama (Beranda, Konselor, Jurnal, Pulse, InteractiveRoomCard)
  static const double lg = 24.0;
  static const Radius radiusLg = Radius.circular(lg);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);

  /// Radius 32px: Floating navigation bar dan top corners bottom modal sheets
  static const double xl = 32.0;
  static const Radius radiusXl = Radius.circular(xl);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: radiusXl,
    topRight: radiusXl,
  );

  /// Radius 100px: Pill badges, status chips, circular icon buttons
  static const double full = 100.0;
  static const Radius radiusFull = Radius.circular(full);
  static const BorderRadius borderFull = BorderRadius.all(radiusFull);
}
