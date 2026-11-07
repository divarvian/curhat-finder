import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/beranda/presentation/widgets/dialogs/create_tip_sheet.dart';

void main() {
  group('CreateTipSheet Widget Tests', () {
    testWidgets('CreateTipSheet renders category selector, inputs, and submit button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateTipSheet(initialCategory: 'Productivity'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Bagikan Tips & Saran ✨'), findsOneWidget);
      expect(find.text('Kategori:'), findsOneWidget);
      expect(find.text('Productivity'), findsOneWidget);
      expect(find.text('Self-care'), findsOneWidget);
      expect(find.text('Judul Tips (Opsional)'), findsOneWidget);
      expect(find.text('Isi Tips / Saran *'), findsOneWidget);
      expect(find.text('Bagikan Tips Sekarang'), findsOneWidget);
    });
  });
}
