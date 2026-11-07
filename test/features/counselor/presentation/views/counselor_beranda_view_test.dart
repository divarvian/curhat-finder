import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_beranda_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('CounselorBerandaView Tests', () {
    testWidgets('CounselorBerandaView renders greeting and mascot correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CounselorBerandaView()),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Halo'), findsOneWidget);
      expect(find.text('Antrean Masuk Mahasiswa'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Counselor header standardized to height 260 and mascot width 200', (tester) async {
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
            home: Scaffold(
              body: CounselorBerandaView(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Halo Sarah Amalia,\nada apa hari ini?'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // Find the top header container with counselorHeaderBg
      final containers = tester.widgetList<Container>(find.byType(Container));
      final headerContainer = containers.firstWhere(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).color == AppColors.counselorHeaderBg,
      );
      expect(headerContainer, isNotNull);
      final boxDecoration = headerContainer.decoration as BoxDecoration;
      expect(boxDecoration.color, AppColors.counselorHeaderBg);

      // Verify mascot SizedBox has width 200
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final mascotBox = sizedBoxes.firstWhere((b) => b.width == 200);
      expect(mascotBox, isNotNull);
    });

    testWidgets('CounselorBerandaView renders HeaderGreetingSkeleton, CounselorStatsSkeleton, and CounselorQueueCardSkeleton when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                const CounselorState(isLoading: true),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorBerandaView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(HeaderGreetingSkeleton), findsOneWidget);
      expect(find.byType(CounselorStatsSkeleton), findsOneWidget);
      expect(find.byType(CounselorQueueCardSkeleton), findsNWidgets(2));
    });
    testWidgets('CounselorBerandaView avatar NetworkImage configures frameBuilder for zero blank flicker', (tester) async {
      final counselor = CounselorProfile.empty.copyWith(
        name: 'Sarah Amalia',
        email: 'sarah@ub.ac.id',
        faculty: 'Fisip',
        studyProgram: 'Psikologi',
        batchYear: '2022',
        gender: 'Perempuan',
        role: 'Konselor',
        avatarUrl: 'https://supabase.example.com/storage/v1/object/public/avatars/counselor_sarah.jpg',
        topics: ['Overwhelmed'],
        isOnline: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                CounselorState(
                  isLoading: false,
                  profile: counselor,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorBerandaView(),
            ),
          ),
        ),
      );

      await tester.pump();

      final imageFinder = find.byWidgetPredicate(
        (w) => w is Image && w.image is NetworkImage && w.frameBuilder != null,
      );
      expect(imageFinder, findsOneWidget);
    });
  });
}
