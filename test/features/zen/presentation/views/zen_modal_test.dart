import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/zen/presentation/views/zen_modal.dart';

void main() {
  group('ZenModal Tests', () {
    testWidgets('Fase 2: ZenModal renders breathing controls and duration chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ZenModal()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zen Relaksasi'), findsOneWidget);
      expect(find.text('Mulai Latihan'), findsOneWidget);
      expect(find.text('1 Menit'), findsOneWidget);
      expect(find.text('2 Menit'), findsOneWidget);
      expect(find.text('5 Menit'), findsOneWidget);
    });
  });
}
