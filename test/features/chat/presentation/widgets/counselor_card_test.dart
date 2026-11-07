import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/cards/counselor_card.dart';

void main() {
  group('CounselorCard Widget Tests', () {
    testWidgets('Renders counselor card with name, gender, faculty, and topics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounselorCard(
              counselorId: 'counselor-1',
              name: 'Kak Alena',
              gender: 'Perempuan',
              faculty: 'Fakultas Ilmu Komputer (FILKOM)',
              tags: ['Anxiety', 'Akademik'],
              hobbies: ['Membaca', 'Mendengarkan Musik'],
              isOnline: true,
            ),
          ),
        ),
      );

      // Verify counselor details are displayed
      expect(find.text('Kak Alena • Perempuan'), findsOneWidget);
      expect(find.text('Fakultas Ilmu Komputer (FILKOM)'), findsOneWidget);
      expect(find.text('Anxiety'), findsOneWidget);
      expect(find.text('Akademik'), findsOneWidget);
    });

    testWidgets('Renders offline state without green online badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounselorCard(
              counselorId: 'counselor-2',
              name: 'Kak Budi',
              gender: 'Laki-laki',
              faculty: 'Fakultas Teknik (FT)',
              tags: ['Burnout'],
              hobbies: ['Olahraga'],
              isOnline: false,
            ),
          ),
        ),
      );

      expect(find.text('Kak Budi • Laki-laki'), findsOneWidget);
      expect(find.text('Fakultas Teknik (FT)'), findsOneWidget);
      expect(find.text('Burnout'), findsOneWidget);
    });

    testWidgets('Renders max 2 topics and +N badge when counselor has more than 2 topics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounselorCard(
              counselorId: 'counselor-3',
              name: 'Kak Citra',
              gender: 'Perempuan',
              faculty: 'Fakultas Kedokteran (FK)',
              tags: ['Akademik', 'Kecemasan', 'Burnout', 'Relasi'],
              hobbies: ['Menulis'],
              isOnline: true,
            ),
          ),
        ),
      );

      // Only the first 2 topics should be rendered on the card
      expect(find.text('Akademik'), findsOneWidget);
      expect(find.text('Kecemasan'), findsOneWidget);
      // Remaining topics should not be on the card, replaced by +2
      expect(find.text('+2'), findsOneWidget);
      expect(find.text('Burnout'), findsNothing);
      expect(find.text('Relasi'), findsNothing);
    });
  });
}
