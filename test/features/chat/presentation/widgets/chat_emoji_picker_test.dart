import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:curhat_finder/features/chat/presentation/views/chat_room_view.dart';

void main() {
  group('Chat Emoji Picker Widget Tests', () {
    testWidgets('Toggles emoji keyboard and switches icon in ChatRoomView', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatRoomView(
              counselorName: 'Kak Test',
              isOnline: true,
              sessionId: '',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially, emoji icon is shown, EmojiPicker is not visible
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
      expect(find.byType(EmojiPicker), findsNothing);

      // Tap emoji button
      await tester.tap(find.byIcon(Icons.emoji_emotions_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // EmojiPicker should now be rendered, icon changes to keyboard
      expect(find.byIcon(Icons.keyboard_outlined), findsOneWidget);
      expect(find.byType(EmojiPicker), findsOneWidget);

      // Tap again to switch back
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
      expect(find.byType(EmojiPicker), findsNothing);
    });
  });
}
