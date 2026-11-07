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

    testWidgets('PulseView renders ULTKSP and LKM cards with contact buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PulseView()),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Layanan Utama & Darurat'), findsOneWidget);
      expect(find.text('Kontak Darurat ULTKSP'), findsOneWidget);
      expect(find.textContaining('Unit Layanan Kekerasan Seksual & Perundungan'), findsWidgets);
      expect(find.text('Layanan Konseling Mahasiswa (LKM)'), findsOneWidget);
      expect(find.text('Telepon'), findsWidgets);
      expect(find.text('Whatsapp'), findsWidgets);
    });

    testWidgets('Tapping circular info button displays institutional explanation sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PulseView()),
          ),
        ),
      );

      await tester.pump();

      // Find circular info button by icon
      final infoButtonFinder = find.byIcon(Icons.info_outline_rounded);
      expect(infoButtonFinder, findsWidgets);

      // Tap the first circular info button (in header)
      await tester.tap(infoButtonFinder.first);
      await tester.pumpAndSettle();

      // Verify bottom sheet title and content
      expect(find.text('Tentang ULTKSP & LKM'), findsOneWidget);
      expect(find.text('Panduan layanan resmi Universitas Brawijaya'), findsOneWidget);
      expect(find.text('Saya Mengerti'), findsOneWidget);

      // Tap close icon button to dismiss
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Tentang ULTKSP & LKM'), findsNothing);
    });
  });
}
