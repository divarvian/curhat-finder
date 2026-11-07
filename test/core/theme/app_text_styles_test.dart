import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';

void main() {
  group('AppTextStyles Tests', () {
    test('AppTextStyles provides accessible, non-negative letter spacing and comfortable line height', () {
      // Body text validation according to WCAG 2.1 & BDA guidelines
      expect(AppTextStyles.bodyLarge.letterSpacing, greaterThanOrEqualTo(0.15));
      expect(AppTextStyles.bodyLarge.height, greaterThanOrEqualTo(1.4));

      expect(AppTextStyles.bodyMedium.letterSpacing, greaterThanOrEqualTo(0.15));
      expect(AppTextStyles.bodyMedium.height, greaterThanOrEqualTo(1.4));

      expect(AppTextStyles.bodySmall.letterSpacing, greaterThanOrEqualTo(0.2));
      expect(AppTextStyles.bodySmall.height, greaterThanOrEqualTo(1.4));

      // Display and Heading validation (neutral or mild tracking, never -5%)
      expect(AppTextStyles.heading1.letterSpacing, greaterThanOrEqualTo(0.0));
      expect(AppTextStyles.heading2.letterSpacing, greaterThanOrEqualTo(0.0));
      expect(AppTextStyles.displayLarge.letterSpacing, greaterThanOrEqualTo(-0.5));
    });
  });
}
