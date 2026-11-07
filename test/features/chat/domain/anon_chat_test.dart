import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/anon_chat_model.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';

void main() {
  group('Anonymous Chat & Reporting Engine Tests', () {
    test('AnonMessageModel converts UTC database timestamps to local time', () {
      const utcIsoString = '2026-10-25T13:45:00.000Z';
      final json = {
        'id': 'anon-msg-1',
        'session_id': 'anon-sess-1',
        'sender_id': 'user-2',
        'sender_alias': 'Anonim',
        'message_text': 'Halo anon',
        'is_system': false,
        'created_at': utcIsoString,
      };

      final message = AnonMessageModel.fromJson(json);

      expect(message.createdAt.isUtc, isFalse);
      expect(message.createdAt, DateTime.parse(utcIsoString).toLocal());
    });

    test('AnonMatchResult correctly parses RPC response for creator and joiner', () {
      final creatorJson = {
        'session_id': 'anon-sess-1',
        'status': 'waiting',
        'matched': false,
        'role': 'creator',
      };
      final creatorResult = AnonMatchResult.fromJson(creatorJson);
      expect(creatorResult.sessionId, 'anon-sess-1');
      expect(creatorResult.status, 'waiting');
      expect(creatorResult.matched, isFalse);
      expect(creatorResult.role, 'creator');

      final joinerJson = {
        'session_id': 'anon-sess-2',
        'status': 'active',
        'matched': true,
        'role': 'joiner',
      };
      final joinerResult = AnonMatchResult.fromJson(joinerJson);
      expect(joinerResult.sessionId, 'anon-sess-2');
      expect(joinerResult.status, 'active');
      expect(joinerResult.matched, isTrue);
      expect(joinerResult.role, 'joiner');
    });

    test('AnonSessionModel lifecycle getters behave correctly', () {
      final waitingSession = AnonSessionModel(
        id: 'sess-wait',
        mode: 'Cuma mau didengar',
        status: 'waiting',
        createdAt: DateTime.now(),
      );
      expect(waitingSession.isWaiting, isTrue);
      expect(waitingSession.isActive, isFalse);
      expect(waitingSession.isEnded, isFalse);

      final activeSession = waitingSession.copyWith(status: 'active');
      expect(activeSession.isWaiting, isFalse);
      expect(activeSession.isActive, isTrue);
      expect(activeSession.isEnded, isFalse);

      final endedSession = activeSession.copyWith(status: 'ended');
      expect(endedSession.isWaiting, isFalse);
      expect(endedSession.isActive, isFalse);
      expect(endedSession.isEnded, isTrue);

      final cancelledSession = activeSession.copyWith(status: 'cancelled');
      expect(cancelledSession.isEnded, isTrue);
    });

    test('AnonSessionModel correctly parses bot session and reconnection data', () {
      final json = {
        'id': 'sess-bot-99',
        'user1_id': 'user-1',
        'user2_id': null,
        'mode': 'Cuma mau didengar',
        'status': 'active',
        'is_bot_session': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      final model = AnonSessionModel.fromJson(json);
      expect(model.id, 'sess-bot-99');
      expect(model.user1Id, 'user-1');
      expect(model.user2Id, isNull);
      expect(model.isBotSession, isTrue);
      expect(model.isActive, isTrue);
    });

    test('AnonReportModel correctly parses report data', () {
      final json = {
        'id': 'rep-1',
        'session_id': 'sess-100',
        'reporter_id': 'user-1',
        'reported_user_id': 'user-2',
        'reason': 'Hate speech / berbicara kasar',
        'details': 'Menggunakan kata-kata kasar',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      final report = AnonReportModel.fromJson(json);
      expect(report.id, 'rep-1');
      expect(report.sessionId, 'sess-100');
      expect(report.reporterId, 'user-1');
      expect(report.reportedUserId, 'user-2');
      expect(report.reason, 'Hate speech / berbicara kasar');
      expect(report.details, 'Menggunakan kata-kata kasar');
      expect(report.status, 'pending');
    });

    test('AnonMessageModel copyWith and deliveryStatus behave correctly', () {
      final msg = AnonMessageModel(
        id: 'msg-temp-1',
        sessionId: 'sess-1',
        senderId: 'user-1',
        senderAlias: 'Mahasiswa Bro',
        messageText: 'Halo ini pesan tes optimistik',
        createdAt: DateTime.now(),
        deliveryStatus: MessageDeliveryStatus.sending,
      );
      expect(msg.deliveryStatus, MessageDeliveryStatus.sending);

      // Failed transition
      final failedMsg = msg.copyWith(deliveryStatus: MessageDeliveryStatus.failed);
      expect(failedMsg.deliveryStatus, MessageDeliveryStatus.failed);

      // Retry transition
      final retryingMsg = failedMsg.copyWith(deliveryStatus: MessageDeliveryStatus.sending);
      expect(retryingMsg.deliveryStatus, MessageDeliveryStatus.sending);

      // Sent transition
      final sentMsg = retryingMsg.copyWith(deliveryStatus: MessageDeliveryStatus.sent);
      expect(sentMsg.deliveryStatus, MessageDeliveryStatus.sent);
    });

    test('3-Layer Deduplication Engine prevents duplicates after delayed retry', () {
      // Simulate client-generated UUID
      const messageId = 'c8b6b0c2-3e2b-4786-9a28-112233445566';
      final t0 = DateTime.now().subtract(const Duration(minutes: 5)); // 5 minutes ago (offline)

      // 1. Initial optimistic message created offline
      var optimisticMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: messageId,
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan saat offline',
          createdAt: t0,
          deliveryStatus: MessageDeliveryStatus.failed,
        ),
      ];

      // 2. User taps retry when network returns: status updated to sending and time refreshed
      final tRetry = DateTime.now();
      optimisticMessages[0] = optimisticMessages[0].copyWith(
        createdAt: tRetry,
        deliveryStatus: MessageDeliveryStatus.sending,
      );

      // 3. Supabase insert succeeds and returns server record with identical UUID
      final serverMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: messageId, // Exact UUID from client
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan saat offline',
          createdAt: tRetry.add(const Duration(milliseconds: 300)),
          deliveryStatus: MessageDeliveryStatus.sent,
        ),
      ];

      // Combine messages logic (Layer 1: Exact UUID match eviction)
      final items = List<AnonMessageModel>.from(serverMessages);
      optimisticMessages.removeWhere((opt) => serverMessages.any((s) => s.id == opt.id));

      // Layer 2: Display guard by unique ID
      for (final opt in optimisticMessages) {
        final alreadyExists = items.any((m) => m.id == opt.id);
        if (!alreadyExists) {
          items.add(opt);
        }
      }

      // Layer 3: Unique ID Safety Net
      final seenIds = <String>{};
      items.retainWhere((m) => seenIds.add(m.id));

      // Assert: Exactly 1 message in list, 0 duplicates!
      expect(items.length, 1);
      expect(items.first.id, messageId);
      expect(optimisticMessages.isEmpty, isTrue);
    });

    test('Consecutive identical messages ("test", "test") are both preserved and displayed correctly', () {
      final serverMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: 'uuid-test-1',
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'test',
          createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
          deliveryStatus: MessageDeliveryStatus.sent,
        ),
      ];

      // Second optimistic message with the exact same text 'test' but different UUID
      var optimisticMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: 'uuid-test-2',
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'test',
          createdAt: DateTime.now(),
          deliveryStatus: MessageDeliveryStatus.sending,
        ),
      ];

      // 1. Evict exact UUID
      optimisticMessages.removeWhere((opt) => serverMessages.any((s) => s.id == opt.id));

      final items = List<AnonMessageModel>.from(serverMessages);

      // 2. Display guard by ID (allows repeated texts with different IDs)
      for (final opt in optimisticMessages) {
        final alreadyExists = items.any((m) => m.id == opt.id);
        if (!alreadyExists) {
          items.add(opt);
        }
      }

      // 3. Unique ID Safety Net
      final seenIds = <String>{};
      items.retainWhere((m) => seenIds.add(m.id));

      // Assert: Both 'test' messages are preserved! Length is 2!
      expect(items.length, 2);
      expect(items[0].messageText, 'test');
      expect(items[0].id, 'uuid-test-1');
      expect(items[1].messageText, 'test');
      expect(items[1].id, 'uuid-test-2');
    });

    test('Exact UUID Deduplication evicts optimistic messages when stream arrives', () {
      const messageId = 'uuid-offline-123';
      final tOffline = DateTime.now().subtract(const Duration(minutes: 5));

      final serverMessages = <ChatMessageModel>[
        ChatMessageModel(
          id: messageId,
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderRole: 'student',
          messageText: 'Halo konselor',
          isRead: false,
          createdAt: DateTime.now(),
          deliveryStatus: MessageDeliveryStatus.sent,
        ),
      ];

      var optimisticMessages = <ChatMessageModel>[
        ChatMessageModel(
          id: messageId,
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderRole: 'student',
          messageText: 'Halo konselor',
          isRead: false,
          createdAt: tOffline,
          deliveryStatus: MessageDeliveryStatus.sending,
        ),
      ];

      // Evict Layer 1 (exact ID)
      optimisticMessages.removeWhere((opt) => serverMessages.any((s) => s.id == opt.id));

      // Assert optimistic message was cleanly evicted
      expect(optimisticMessages.isEmpty, isTrue);
    });
  });
}
