import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/typing_indicator_bubble.dart';

void main() {
  group('TypingIndicatorBubble Widget Tests', () {
    testWidgets('Renders typing status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicatorBubble(
              peerName: 'Kak Alena',
              status: 'typing',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kak Alena sedang mengetik...'), findsOneWidget);
    });

    testWidgets('Renders choosing emoji status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicatorBubble(
              peerName: 'Kak Alena',
              status: 'choosing_emoji',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kak Alena sedang memilih emoji...'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
    });
  });
}
