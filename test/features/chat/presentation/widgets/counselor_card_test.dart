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

    testWidgets('Renders only topics that fit horizontally without any +1 or +N badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: CounselorCard(
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
        ),
      );

      // On 400px width, 3 topics fit
      expect(find.text('Akademik'), findsOneWidget);
      expect(find.text('Kecemasan'), findsOneWidget);
      expect(find.text('Burnout'), findsOneWidget);

      // Topic that exceeds width is not rendered
      expect(find.text('Relasi'), findsNothing);

      // Verify NO +1 or +N badge is rendered
      expect(find.text('+1'), findsNothing);
      expect(find.text('+2'), findsNothing);
    });

    testWidgets('Renders fewer topics on narrower screen without +N badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: CounselorCard(
                counselorId: 'counselor-4',
                name: 'Kak Dedi',
                gender: 'Laki-laki',
                faculty: 'Fakultas Teknik (FT)',
                tags: ['Akademik', 'Kecemasan', 'Burnout', 'Relasi'],
                hobbies: ['Membaca'],
                isOnline: true,
              ),
            ),
          ),
        ),
      );

      // On 300px width, exactly 2 topics fit
      expect(find.text('Akademik'), findsOneWidget);
      expect(find.text('Kecemasan'), findsOneWidget);
      expect(find.text('Burnout'), findsNothing);
      expect(find.text('Relasi'), findsNothing);

      // Verify NO +1 or +N badge is rendered
      expect(find.text('+1'), findsNothing);
      expect(find.text('+2'), findsNothing);
    });
  });
}
