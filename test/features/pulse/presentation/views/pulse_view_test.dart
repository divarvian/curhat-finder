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

    testWidgets('PulseView renders unified emergency card matching canonical mockup', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PulseView()),
          ),
        ),
      );

      await tester.pump();
      // Unified emergency card title and subtitle
      expect(find.text('Kontak Darurat\nULTKSP & LKM'), findsOneWidget);
      expect(find.textContaining('Unit Layanan Terpadu Krisis'), findsOneWidget);

      // Buttons inside unified emergency card
      expect(find.text('ULTKSP'), findsOneWidget);
      expect(find.text('LKM'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

      // Faculty section and "Hubungi" buttons
      expect(find.text('Kontak per Fakultas'), findsOneWidget);
      expect(find.text('Hubungi'), findsWidgets);

      // Category filter chevrons
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('Tapping ULTKSP button opens contact action sheet with Telepon and WhatsApp', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PulseView()),
          ),
        ),
      );

      await tester.pump();

      // Tap ULTKSP button
      await tester.tap(find.text('ULTKSP'));
      await tester.pumpAndSettle();

      // Verify action sheet
      expect(find.text('Kontak Darurat ULTKSP'), findsOneWidget);
      expect(find.textContaining('Panggilan Telepon'), findsOneWidget);
      expect(find.text('Chat WhatsApp Resmi'), findsOneWidget);

      // Dismiss
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Kontak Darurat ULTKSP'), findsNothing);
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

      // Tap circular info button (i)
      final infoButtonFinder = find.byIcon(Icons.info_outline_rounded);
      expect(infoButtonFinder, findsOneWidget);

      await tester.tap(infoButtonFinder);
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
