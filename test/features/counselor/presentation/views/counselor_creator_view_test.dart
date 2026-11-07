import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_creator_view.dart';

void main() {
  group('CounselorCreatorView Tests', () {
    testWidgets('Fase 3: CounselorCreatorView renders in-place creation form matching Creator.png', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CounselorCreatorView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Creator'), findsOneWidget);
      expect(find.text('Kategori Tips'), findsOneWidget);
      expect(find.text('Judul Tips *'), findsOneWidget);
      expect(find.text('Isi Ringkasan *'), findsOneWidget);
      expect(find.text('Isi *'), findsOneWidget);
      expect(find.text('Link Eksternal (Opsional)'), findsOneWidget);
      expect(find.text('Publikasikan Tips'), findsOneWidget);
      expect(find.text('H2'), findsOneWidget);
    });
  });
}
