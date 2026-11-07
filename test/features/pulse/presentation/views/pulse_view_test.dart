import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/pulse/presentation/providers/pulse_provider.dart';
import 'package:curhat_finder/features/pulse/presentation/views/pulse_view.dart';

void main() {
  group('PulseView Tests', () {
    test('PulseNotifier categories delegating to AcademicHelper includes Semua and faculties', () {
      final categories = PulseNotifier.categories;
      expect(categories.first, 'Semua');
      expect(categories, contains('FILKOM'));
      expect(categories, contains('FT'));
      expect(categories, contains('FK'));
    });

    testWidgets('PulseView renders emergency card and contact buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PulseView()),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Kontak Darurat ULTKSP'), findsOneWidget);
      expect(find.textContaining('Unit Layanan Terpadu Krisis'), findsOneWidget);
      expect(find.text('Telepon'), findsWidgets);
      expect(find.text('Whatsapp'), findsWidgets);
    });
  });
}
