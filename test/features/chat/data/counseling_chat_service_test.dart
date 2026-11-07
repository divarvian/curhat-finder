import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/anon_chat_model.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';

void main() {
  group('Read Receipts & Presence Engine Tests', () {
    test('AnonMessageModel maps is_read = true to MessageDeliveryStatus.read and false to sent', () {
      final unreadJson = {
        'id': 'msg-1',
        'session_id': 'sess-1',
        'sender_id': 'user-1',
        'sender_alias': 'Anonim 1',
        'message_text': 'Pesan belum dibaca',
        'is_system': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      final readJson = {
        'id': 'msg-2',
        'session_id': 'sess-1',
        'sender_id': 'user-1',
        'sender_alias': 'Anonim 1',
        'message_text': 'Pesan sudah dibaca',
        'is_system': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': true,
      };

      final unreadModel = AnonMessageModel.fromJson(unreadJson);
      final readModel = AnonMessageModel.fromJson(readJson);

      expect(unreadModel.isRead, false);
      expect(unreadModel.deliveryStatus, MessageDeliveryStatus.sent);

      expect(readModel.isRead, true);
      expect(readModel.deliveryStatus, MessageDeliveryStatus.read);
    });

    test('Activity-based heartbeat logic identifies partner message to keep session online', () {
      const currentUserId = 'user-me';
      const partnerUserId = 'user-partner';

      final messages = [
        AnonMessageModel(
          id: '1',
          sessionId: 's-1',
          senderId: currentUserId,
          senderAlias: 'Me',
          messageText: 'Halo',
          createdAt: DateTime.now(),
        ),
        AnonMessageModel(
          id: '2',
          sessionId: 's-1',
          senderId: partnerUserId,
          senderAlias: 'Partner',
          messageText: 'Hai juga!',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Logic check as implemented in _handleIncomingMessagesActivity
      final partnerMessages = messages.where((m) =>
        !m.isSystem && (m.senderId != null && m.senderId != currentUserId)
      ).toList();

      expect(partnerMessages.length, 1);
      expect(partnerMessages.first.senderId, partnerUserId);
      final hasUnread = partnerMessages.any((m) => !m.isRead);
      expect(hasUnread, true); // Perlu ditandai sebagai terbaca
    });
  });
}
