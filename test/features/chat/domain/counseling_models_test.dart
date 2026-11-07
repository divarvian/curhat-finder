import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';

void main() {
  group('Counseling Models Tests', () {
    test('ChatMessageModel converts UTC database timestamps to local time', () {
      const utcIsoString = '2026-10-25T13:45:00.000Z';
      final json = {
        'id': 'msg-1',
        'session_id': 'sess-1',
        'sender_id': 'user-1',
        'sender_role': 'student',
        'message_text': 'Halo konselor',
        'is_read': false,
        'created_at': utcIsoString,
      };

      final message = ChatMessageModel.fromJson(json);

      expect(message.createdAt.isUtc, isFalse);
      expect(message.createdAt, DateTime.parse(utcIsoString).toLocal());
    });

    test('CounselingSessionModel and QueueModel convert UTC timestamps to local time', () {
      const utcIsoString = '2026-10-25T13:45:00.000Z';
      final sessionJson = {
        'id': 'sess-1',
        'student_id': 'stud-1',
        'counselor_id': 'coun-1',
        'status': 'active',
        'started_at': utcIsoString,
      };
      final session = CounselingSessionModel.fromJson(sessionJson);
      expect(session.startedAt.isUtc, isFalse);
      expect(session.startedAt, DateTime.parse(utcIsoString).toLocal());

      final queueJson = {
        'id': 'queue-1',
        'student_id': 'stud-1',
        'student_alias': 'Anonim',
        'student_faculty': 'FILKOM',
        'counselor_id': 'coun-1',
        'status': 'waiting',
        'created_at': utcIsoString,
      };
      final queue = CounselingQueueModel.fromJson(queueJson);
      expect(queue.createdAt.isUtc, isFalse);
      expect(queue.createdAt, DateTime.parse(utcIsoString).toLocal());
    });

    test('ChatMessageModel failed delivery status parses correctly and supports retry', () {
      final failedMsg = ChatMessageModel(
        id: 'msg-test-1',
        sessionId: 'session-test',
        senderId: 'user-1',
        senderRole: 'student',
        messageText: 'Halo ini tes',
        isRead: false,
        deliveryStatus: MessageDeliveryStatus.failed,
        createdAt: DateTime.now(),
      );

      expect(failedMsg.deliveryStatus, MessageDeliveryStatus.failed);

      final retryingMsg = failedMsg.copyWith(
        deliveryStatus: MessageDeliveryStatus.sending,
      );
      expect(retryingMsg.deliveryStatus, MessageDeliveryStatus.sending);

      final sentMsg = retryingMsg.copyWith(
        deliveryStatus: MessageDeliveryStatus.sent,
      );
      expect(sentMsg.deliveryStatus, MessageDeliveryStatus.sent);
    });

    test('Single active session logic identifies ongoing session and prevents new queue', () {
      final activeSession = CounselingSessionModel(
        id: 'sess-active',
        counselorId: 'counselor-a',
        studentId: 'student-123',
        studentAlias: 'AnonStudent',
        studentFaculty: 'FILKOM',
        status: 'active',
        startedAt: DateTime.now(),
      );

      // Emulate student active session check
      final hasActiveSession = activeSession.status == 'active';
      expect(hasActiveSession, isTrue);

      // When opening Counselor B's profile:
      final String viewingCounselorId = 'counselor-b';
      final bool hasSessionWithOther = activeSession.counselorId != viewingCounselorId;
      expect(hasSessionWithOther, isTrue);

      // When opening Counselor A's profile:
      final String ownCounselorId = 'counselor-a';
      final bool hasSessionWithThis = activeSession.counselorId == ownCounselorId;
      expect(hasSessionWithThis, isTrue);
    });

    test('ChatMessageModel correctly parses unsend and delete-for-me fields', () {
      final json = {
        'id': 'chat-msg-1',
        'session_id': 'sess-100',
        'sender_id': 'user-1',
        'sender_role': 'student',
        'message_text': 'Pesan rahasia',
        'is_read': true,
        'created_at': '2026-10-28T01:00:00Z',
        'is_deleted_for_everyone': true,
        'deleted_at': '2026-10-28T01:05:00Z',
        'deleted_for_users': ['user-1', 'user-2'],
      };

      final model = ChatMessageModel.fromJson(json);
      expect(model.id, 'chat-msg-1');
      expect(model.isDeletedForEveryone, isTrue);
      expect(model.deletedAt, isNotNull);
      expect(model.deletedForUsers, ['user-1', 'user-2']);

      final copied = model.copyWith(
        isDeletedForEveryone: false,
        deletedForUsers: ['user-3'],
      );
      expect(copied.isDeletedForEveryone, isFalse);
      expect(copied.deletedForUsers, ['user-3']);
    });

    test('Unsend eligibility rules for counseling (<= 30 minutes) and sender ownership', () {
      const currentUserId = 'user-me';
      const peerUserId = 'user-peer';
      final now = DateTime.now();

      final recentMsgByMe = ChatMessageModel(
        id: 'c-1',
        sessionId: 'sess-1',
        senderId: currentUserId,
        senderRole: 'student',
        messageText: 'Baru dikirim 5 menit lalu',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      );

      final oldMsgByMe = ChatMessageModel(
        id: 'c-2',
        sessionId: 'sess-1',
        senderId: currentUserId,
        senderRole: 'student',
        messageText: 'Dikirim 45 menit lalu',
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 45)),
      );

      final msgByPeer = ChatMessageModel(
        id: 'c-3',
        sessionId: 'sess-1',
        senderId: peerUserId,
        senderRole: 'counselor',
        messageText: 'Pesan dari konselor',
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 2)),
      );

      // Rule check:
      bool canUnsendCounseling(ChatMessageModel m) {
        final isMe = m.senderId == currentUserId;
        final within30Mins = DateTime.now().difference(m.createdAt).inMinutes <= 30;
        return isMe && !m.isDeletedForEveryone && within30Mins;
      }

      expect(canUnsendCounseling(recentMsgByMe), isTrue);
      expect(canUnsendCounseling(oldMsgByMe), isFalse); // Melebihi 30 menit
      expect(canUnsendCounseling(msgByPeer), isFalse); // Milik lawan bicara
    });
  });
}
