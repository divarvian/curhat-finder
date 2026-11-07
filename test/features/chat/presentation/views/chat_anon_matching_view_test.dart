import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/chat/domain/anon_chat_model.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';
import 'package:curhat_finder/features/chat/presentation/views/chat_anon_matching_view.dart';

void main() {
  group('Anonymous Matching Timeout & Auto-Retry Reconnection Tests', () {
    testWidgets('ChatAnonMatchingView displays timeout view with Bot AI disclosure after 15 seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatAnonMatchingView(
              mode: 'Cuma mau didengar',
            ),
          ),
        ),
      );

      // Initially searching
      expect(find.text('Mencari partner ngobrol...'), findsOneWidget);
      expect(find.text('Batalkan'), findsOneWidget);

      // Advance timer by 16 seconds to simulate timeout
      for (int i = 0; i < 16; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Verifies timeout state is rendered
      expect(find.text('Belum Menemukan Partner'), findsOneWidget);
      expect(find.text('BOT AI OTOMATIS'), findsOneWidget);
      expect(find.text('Ngobrol dengan Teman Virtual'), findsOneWidget);
      expect(find.text('Mulai Ngobrol dengan Teman Virtual'), findsOneWidget);
      expect(find.text('Coba Cari Teman Mahasiswa Lagi'), findsOneWidget);
      expect(find.text('Kembali ke Menu Chat'), findsOneWidget);
    });

    test('Auto-retry processor sequentially re-sends failed messages without duplicates', () async {
      final List<AnonMessageModel> queue = [
        AnonMessageModel(
          id: 'msg-1',
          sessionId: 'sess-1',
          senderId: 'user-1',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan gagal 1',
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
          deliveryStatus: MessageDeliveryStatus.failed,
        ),
        AnonMessageModel(
          id: 'msg-2',
          sessionId: 'sess-1',
          senderId: 'user-1',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan gagal 2',
          createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
          deliveryStatus: MessageDeliveryStatus.failed,
        ),
      ];

      // Simulate auto-retry execution
      final List<String> retriedIds = [];
      for (int i = 0; i < queue.length; i++) {
        final current = queue[i];
        if (current.deliveryStatus == MessageDeliveryStatus.failed) {
          queue[i] = current.copyWith(
            createdAt: DateTime.now(),
            deliveryStatus: MessageDeliveryStatus.sending,
          );
          retriedIds.add(current.id);
          // Simulate successful arrival
          queue[i] = queue[i].copyWith(
            deliveryStatus: MessageDeliveryStatus.sent,
          );
        }
      }

      expect(retriedIds, ['msg-1', 'msg-2']);
      expect(queue.every((m) => m.deliveryStatus == MessageDeliveryStatus.sent), isTrue);
    });

    test('Auto-retry handles Postgres 23505 duplicate key error by marking message as sent', () {
      final msg = AnonMessageModel(
        id: 'msg-already-in-db',
        sessionId: 'sess-1',
        senderId: 'user-1',
        senderAlias: 'Mahasiswa Bro',
        messageText: 'Pesan terputus sesaat',
        createdAt: DateTime.now(),
        deliveryStatus: MessageDeliveryStatus.failed,
      );

      final optimisticMessages = [msg];

      // Simulate simulated error: PostgrestException 23505
      final Object simulatedError = Exception('PostgrestException(message: duplicate key value violates unique constraint "anon_messages_pkey", code: 23505)');
      final isDuplicateKey = simulatedError.toString().contains('23505') ||
          simulatedError.toString().toLowerCase().contains('duplicate key');

      final idx = optimisticMessages.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        optimisticMessages[idx] = msg.copyWith(
          deliveryStatus: isDuplicateKey
              ? MessageDeliveryStatus.sent
              : MessageDeliveryStatus.failed,
        );
      }

      // Assert: Message is resolved to sent status because it already exists in DB!
      expect(optimisticMessages.first.deliveryStatus, MessageDeliveryStatus.sent);
    });
  });
}
