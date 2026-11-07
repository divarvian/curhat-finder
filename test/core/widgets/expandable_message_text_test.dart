import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/expandable_message_text.dart';

void main() {
  group('ExpandableMessageText Widget Tests', () {
    testWidgets('CHAT-004: ExpandableMessageText handles short and long text properly', (WidgetTester tester) async {
      const shortText = 'Halo ini pesan singkat di bawah batas karakter.';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpandableMessageText(
              text: shortText,
              style: TextStyle(fontSize: 14),
              isMe: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(shortText), findsOneWidget);
      expect(find.text('Baca selengkapnya'), findsNothing);
      expect(find.text('Tampilkan lebih sedikit'), findsNothing);

      // Long text test (> 360 characters)
      final longText = 'Kalimat pembuka yang cukup panjang untuk menguji fitur expandable text. ' * 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableMessageText(
              text: longText,
              style: const TextStyle(fontSize: 14),
              isMe: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially truncated
      expect(find.text('Baca selengkapnya'), findsOneWidget);
      expect(find.text('Tampilkan lebih sedikit'), findsNothing);

      // Tap "Baca selengkapnya"
      await tester.tap(find.text('Baca selengkapnya'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.text('Tampilkan lebih sedikit'), findsOneWidget);
      expect(find.text('Baca selengkapnya'), findsNothing);
      expect(find.text(longText), findsOneWidget);

      // Tap "Tampilkan lebih sedikit" to collapse
      await tester.tap(find.text('Tampilkan lebih sedikit'));
      await tester.pumpAndSettle();

      expect(find.text('Baca selengkapnya'), findsOneWidget);
      expect(find.text('Tampilkan lebih sedikit'), findsNothing);
    });
  });
}
