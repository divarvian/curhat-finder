import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';
import 'package:curhat_finder/features/chat/data/counseling_service.dart';

void main() {
  group('Session-Scoped Cache & Queue Deduplication Tests', () {
    test('CounselingService isolates chat cache strictly per sessionId', () {
      final service = CounselingService();

      final msgSessionA = ChatMessageModel(
        id: 'msg-a',
        sessionId: 'session-a',
        senderId: 'stud-1',
        senderRole: 'student',
        messageText: 'Pesan Sesi A',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final msgSessionB = ChatMessageModel(
        id: 'msg-b',
        sessionId: 'session-b',
        senderId: 'stud-1',
        senderRole: 'student',
        messageText: 'Pesan Sesi B Baru',
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Cache session A and B
      service.updateSessionCache('session-a', [msgSessionA]);
      service.updateSessionCache('session-b', [msgSessionB]);

      expect(service.getSessionCache('session-a').length, 1);
      expect(service.getSessionCache('session-a').first.messageText, 'Pesan Sesi A');

      expect(service.getSessionCache('session-b').length, 1);
      expect(service.getSessionCache('session-b').first.messageText, 'Pesan Sesi B Baru');

      // Clear session A upon completion
      service.clearSessionCache('session-a');
      expect(service.getSessionCache('session-a'), isEmpty);

      // Session B remains intact without memory leak or cache collision
      expect(service.getSessionCache('session-b').length, 1);
      expect(service.getSessionCache('session-b').first.messageText, 'Pesan Sesi B Baru');

      // A new session C with the same user starts completely fresh (empty cache)
      expect(service.getSessionCache('session-c'), isEmpty);
    });

    test('Deduplication logic resolves to exactly 1 latest queue per student', () {
      final oldQueue = CounselingQueueModel(
        id: 'q-old',
        studentId: 'student-123',
        studentAlias: 'Anon-A',
        studentGender: 'Perempuan',
        studentFaculty: 'FILKOM',
        assignedCounselorId: 'counselor-1',
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      final newQueue = CounselingQueueModel(
        id: 'q-new',
        studentId: 'student-123',
        studentAlias: 'Anon-A',
        studentGender: 'Perempuan',
        studentFaculty: 'FILKOM',
        assignedCounselorId: 'counselor-1',
        status: 'waiting',
        createdAt: DateTime.now(),
      );

      final anotherStudentQueue = CounselingQueueModel(
        id: 'q-other',
        studentId: 'student-456',
        studentAlias: 'Anon-B',
        studentGender: 'Laki-laki',
        studentFaculty: 'FEB',
        assignedCounselorId: 'counselor-1',
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      final rawQueues = [oldQueue, newQueue, anotherStudentQueue];

      // Simulate the deduplication logic used in counselor_provider
      final Map<String, CounselingQueueModel> latestByStudent = {};
      for (final q in rawQueues) {
        if (!latestByStudent.containsKey(q.studentId) ||
            q.createdAt.isAfter(latestByStudent[q.studentId]!.createdAt)) {
          latestByStudent[q.studentId] = q;
        }
      }
      final deduplicated = latestByStudent.values.toList();

      expect(deduplicated.length, 2);
      expect(deduplicated.any((q) => q.id == 'q-new'), isTrue);
      expect(deduplicated.any((q) => q.id == 'q-old'), isFalse);
      expect(deduplicated.any((q) => q.id == 'q-other'), isTrue);
    });
  });
}
