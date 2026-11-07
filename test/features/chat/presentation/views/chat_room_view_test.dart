import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/chat/presentation/views/chat_room_view.dart';

void main() {
  group('ChatRoomView Tests', () {
    testWidgets('ChatRoomView allows student to open Akhiri Sesi Konseling dialog', (WidgetTester tester) async {
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

      // Find PopupMenuButton with more_vert icon
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Tap more_vert icon to open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Expect 'Akhiri Sesi Konseling' menu item to be visible
      expect(find.text('Akhiri Sesi Konseling'), findsOneWidget);
      expect(find.text('Privasi & Enkripsi'), findsOneWidget);

      // Tap 'Akhiri Sesi Konseling'
      await tester.tap(find.text('Akhiri Sesi Konseling'));
      await tester.pumpAndSettle();

      // Expect confirmation dialog to be shown
      expect(find.text('Akhiri Sesi Konseling?'), findsOneWidget);
      expect(find.text('Lanjutkan Chat'), findsOneWidget);
      expect(find.text('Akhiri Sesi'), findsOneWidget);

      // Tap 'Lanjutkan Chat' to dismiss dialog
      await tester.tap(find.text('Lanjutkan Chat'));
      await tester.pumpAndSettle();

      expect(find.text('Akhiri Sesi Konseling?'), findsNothing);
    });

    testWidgets('ChatRoomView renders orientation guidance header and icebreaker chips', (WidgetTester tester) async {
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

      expect(find.text('Ruang Aman Konseling Sebaya'), findsOneWidget);
      expect(find.textContaining('Percakapan ini bersifat rahasia dan aman'), findsOneWidget);
      expect(find.text('Lagi overthinking tugas kuliah'), findsOneWidget);
      expect(find.text('Merasa cemas & burnout'), findsOneWidget);
      expect(find.text('Butuh teman dengar dan saran'), findsOneWidget);

      // Tap an icebreaker chip to populate textfield
      await tester.tap(find.text('Lagi overthinking tugas kuliah'));
      await tester.pump();
      expect(find.text('Lagi overthinking tugas kuliah'), findsWidgets);
    });
  });
}
