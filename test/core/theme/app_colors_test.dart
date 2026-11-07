import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';

void main() {
  group('AppColors Tests', () {
    test('Canonical system colors and chat gradient constants have correct values', () {
      expect(AppColors.counselorHeaderBg, const Color(0xFFFCEDED));
      expect(AppColors.counselorRegisterBg, const Color(0xFF8198CF));
      expect(AppColors.counselorRegisterBtn, const Color(0xFFF8D0D0));
      expect(AppColors.studentChatGradientTop, const Color(0xFF93A8D7));
      expect(AppColors.studentChatGradientBottom, const Color(0xFFF4F8FB));
      expect(AppColors.jurnalGradientTop, const Color(0xFFB0BFE2));
      expect(AppColors.jurnalGradientBottom, const Color(0xFFF4F8FB));
    });
  });
}
