import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/counselor_profile_sheet.dart';

void main() {
  group('CounselorProfileSheet Widget Tests', () {
    testWidgets('Shows offline banner and disabled button when counselor is offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselorProfileSheet(
                counselorId: '',
                name: 'Kak Clara',
                gender: 'Perempuan',
                faculty: 'FIB',
                topics: ['Stress'],
                hobbies: ['Menulis'],
                operationalHours: '18:00 - 21:00 WIB',
                isOnline: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Konselor Sedang Offline'), findsOneWidget);
      expect(find.textContaining('Konselor sedang offline'), findsOneWidget);
    });

    testWidgets('Shows start counseling button when counselor is online', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselorProfileSheet(
                counselorId: '',
                name: 'Kak Dito',
                gender: 'Laki-laki',
                faculty: 'FILKOM',
                topics: ['Akademik'],
                hobbies: ['Gaming'],
                operationalHours: '18:00 - 21:00 WIB',
                isOnline: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Mulai melakukan konseling'), findsOneWidget);
    });

    testWidgets('Renders topics horizontally on line 1, not vertically stacked', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselorProfileSheet(
                counselorId: '',
                name: 'Kak Clara',
                gender: 'Perempuan',
                faculty: 'FIB',
                topics: ['Stress', 'Kecemasan', 'Akademik'],
                hobbies: ['Menulis'],
                operationalHours: '18:00 - 21:00 WIB',
                isOnline: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final stressTop = tester.getTopLeft(find.text('Stress')).dy;
      final cemasTop = tester.getTopLeft(find.text('Kecemasan')).dy;
      expect(stressTop, equals(cemasTop));
    });
  });
}
