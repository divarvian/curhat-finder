import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/theme/app_radii.dart';

void main() {
  group('AppRadii Tests', () {
    test('UX-002: AppRadii semantic corner radius tokens', () {
      expect(AppRadii.xs, 4.0);
      expect(AppRadii.sm, 12.0);
      expect(AppRadii.md, 16.0);
      expect(AppRadii.lg, 24.0);
      expect(AppRadii.xl, 32.0);
      expect(AppRadii.full, 100.0);

      expect(AppRadii.radiusXs, const Radius.circular(4.0));
      expect(AppRadii.radiusSm, const Radius.circular(12.0));
      expect(AppRadii.radiusMd, const Radius.circular(16.0));
      expect(AppRadii.radiusLg, const Radius.circular(24.0));
      expect(AppRadii.radiusXl, const Radius.circular(32.0));
      expect(AppRadii.radiusFull, const Radius.circular(100.0));

      expect(AppRadii.borderLg, BorderRadius.circular(24.0));
      expect(AppRadii.borderFull, BorderRadius.circular(100.0));
    });
  });
}
