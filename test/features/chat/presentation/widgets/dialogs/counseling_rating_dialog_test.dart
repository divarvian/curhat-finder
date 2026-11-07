import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/dialogs/counseling_rating_dialog.dart';

void main() {
  group('CounselingRatingDialog Widget Tests', () {
    testWidgets('Renders rating dialog and handles interaction', (WidgetTester tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselingRatingDialog(
                sessionId: '',
                counselorName: 'Kak Alena',
                onSubmitted: () {
                  submitted = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check header and content
      expect(find.text('Sesi Konseling Selesai'), findsOneWidget);
      expect(find.textContaining('Bagaimana pengalaman konselingmu bersama Kak Alena?'), findsOneWidget);
      expect(find.text('Sangat Membantu'), findsOneWidget);
      expect(find.text('Ramah & Empatik'), findsOneWidget);
      expect(find.text('Kirim Ulasan & Selesai'), findsOneWidget);

      // Tap submit button
      await tester.tap(find.text('Kirim Ulasan & Selesai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isTrue);
    });

    testWidgets('Tapping Lewati button triggers onSkipped callback', (WidgetTester tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselingRatingDialog(
                sessionId: '',
                counselorName: 'Kak Alena',
                onSkipped: () {
                  skipped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Lewati'), findsOneWidget);

      // Ensure visible and tap Lewati button
      await tester.ensureVisible(find.text('Lewati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lewati'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(skipped, isTrue);
    });
  });
}
