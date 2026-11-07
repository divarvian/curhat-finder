import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';
import 'package:curhat_finder/features/chat/data/counseling_service.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/active_session_banner.dart';

void main() {
  group('ActiveSessionBanner Widget Tests', () {
    testWidgets('Renders banner when there is an active session', (WidgetTester tester) async {
      final mockSession = CounselingSessionModel(
        id: 'sess-123',
        counselorId: 'counselor-1',
        studentId: 'student-1',
        studentAlias: 'AnonBro',
        studentFaculty: 'FILKOM',
        status: 'active',
        startedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeStudentSessionProvider.overrideWith(
              (ref) => Stream.value([mockSession]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveSessionBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sesi Konseling Sedang Berjalan'), findsOneWidget);
      expect(find.text('Ketuk untuk langsung kembali ke percakapan'), findsOneWidget);
      expect(find.text('Buka Chat'), findsOneWidget);
    });

    testWidgets('Renders empty when there are no active sessions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeStudentSessionProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveSessionBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sesi Konseling Sedang Berjalan'), findsNothing);
    });

    testWidgets('ActiveSessionBanner wraps content in AnimatedSize and AnimatedSwitcher for smooth transition', (WidgetTester tester) async {
      final mockSession = CounselingSessionModel(
        id: 'sess-anim',
        counselorId: 'counselor-1',
        studentId: 'student-1',
        studentAlias: 'AnonBro',
        studentFaculty: 'FILKOM',
        status: 'active',
        startedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeStudentSessionProvider.overrideWith(
              (ref) => Stream.value([mockSession]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveSessionBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AnimatedSize), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Sesi Konseling Sedang Berjalan'), findsOneWidget);
      expect(find.text('Ketuk untuk langsung kembali ke percakapan'), findsOneWidget);
    });

    testWidgets('ActiveSessionBanner has zero FutureBuilder and avoids counselor name blinking', (tester) async {
      final mockSession = CounselingSessionModel(
        id: 'sess-f18',
        counselorId: 'counselor-1',
        studentId: 'student-1',
        studentAlias: 'AnonBro',
        studentFaculty: 'FILKOM',
        status: 'active',
        startedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeStudentSessionProvider.overrideWith(
              (ref) => Stream.value([mockSession]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveSessionBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      // Standardized title is displayed immediately without waiting for FutureBuilder
      expect(find.text('Sesi Konseling Sedang Berjalan'), findsOneWidget);
      expect(find.text('Ketuk untuk langsung kembali ke percakapan'), findsOneWidget);
      expect(find.byType(FutureBuilder), findsNothing);
    });
  });
}
