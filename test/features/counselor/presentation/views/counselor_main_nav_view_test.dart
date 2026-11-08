import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_main_nav_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('CounselorMainNavView Tests', () {
    testWidgets('renders pink gradient background container across all counselor tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                const CounselorState(
                  isLoading: false,
                  currentNavIndex: 0,
                  profile: CounselorProfile(
                    name: 'Sarah Amalia',
                    email: 'sarah@ub.ac.id',
                    faculty: 'Fisip',
                    studyProgram: 'Psikologi',
                    batchYear: '2022',
                    gender: 'Perempuan',
                    role: 'Konselor',
                    avatarPath: 'assets/images/mascot.png',
                    topics: ['Overwhelmed'],
                    isOnline: true,
                    activeSessions: 0,
                    totalHelped: 10,
                    responseTime: '5m',
                  ),
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: CounselorMainNavView(),
          ),
        ),
      );

      await tester.pump();

      // Find Container with LinearGradient
      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.firstWhere(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).gradient is LinearGradient,
      );

      final decoration = gradientContainer.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors, [
        AppColors.counselorChatGradientTop,
        AppColors.counselorChatGradientBottom,
      ]);
    });
  });
}
