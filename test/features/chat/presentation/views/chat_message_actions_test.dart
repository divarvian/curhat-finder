import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/anon_chat_model.dart';

void main() {
  group('Multi-Select, Delete for Me, and Unsend Tests', () {
    test('AnonMessageModel correctly parses unsend and delete-for-me fields', () {
      final json = {
        'id': 'anon-msg-1',
        'session_id': 'anon-sess-100',
        'sender_id': 'user-x',
        'sender_alias': 'Mahasiswa Bro',
        'message_text': 'Cerita rahasia',
        'is_system': false,
        'created_at': '2026-10-28T01:00:00Z',
        'is_deleted_for_everyone': true,
        'deleted_at': '2026-10-28T01:02:00Z',
        'deleted_for_users': ['user-x'],
      };

      final model = AnonMessageModel.fromJson(json);
      expect(model.id, 'anon-msg-1');
      expect(model.isDeletedForEveryone, isTrue);
      expect(model.deletedAt, isNotNull);
      expect(model.deletedForUsers, ['user-x']);
    });

    test('Delete for Me filtering logic excludes messages where deletedForUsers contains currentUserId', () {
      const currentUserId = 'user-me';
      const peerUserId = 'user-peer';

      final messages = [
        AnonMessageModel(
          id: 'msg-1',
          sessionId: 'sess-1',
          senderId: currentUserId,
          senderAlias: 'Me',
          messageText: 'Pesan 1',
          createdAt: DateTime.now(),
          deletedForUsers: const ['user-me'], // Hapus untuk saya
        ),
        AnonMessageModel(
          id: 'msg-2',
          sessionId: 'sess-1',
          senderId: peerUserId,
          senderAlias: 'Peer',
          messageText: 'Pesan 2',
          createdAt: DateTime.now(),
          deletedForUsers: const [], // Tidak dihapus
        ),
        AnonMessageModel(
          id: 'msg-3',
          sessionId: 'sess-1',
          senderId: currentUserId,
          senderAlias: 'Me',
          messageText: 'Pesan 3',
          createdAt: DateTime.now(),
          deletedForUsers: const ['user-other'], // Dihapus orang lain, bukan saya
        ),
      ];

      final visibleToMe = messages.where((m) => !m.deletedForUsers.contains(currentUserId)).toList();
      expect(visibleToMe.length, 2);
      expect(visibleToMe.map((m) => m.id), ['msg-2', 'msg-3']);
    });

    test('Copy formatting includes timestamps correctly for selected messages', () {
      final t1 = DateTime(2026, 10, 28, 14, 30);
      final t2 = DateTime(2026, 10, 28, 14, 32);

      final selected = [
        AnonMessageModel(
          id: 'm-1',
          sessionId: 's-1',
          senderAlias: 'Anon',
          messageText: 'Halo semuanya',
          createdAt: t1,
        ),
        AnonMessageModel(
          id: 'm-2',
          sessionId: 's-1',
          senderAlias: 'Anon',
          messageText: 'Pesan penting',
          createdAt: t2,
        ),
      ];

      final buffer = StringBuffer();
      for (int i = 0; i < selected.length; i++) {
        final m = selected[i];
        final timeStr = '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}';
        final textContent = m.isDeletedForEveryone ? 'Pesan ini telah ditarik' : m.messageText;
        buffer.write('[$timeStr] $textContent');
        if (i < selected.length - 1) {
          buffer.write('\n');
        }
      }

      expect(buffer.toString(), '[14:30] Halo semuanya\n[14:32] Pesan penting');
    });

    test('Deleted message text omits emoji 🚫 in copy formatting', () {
      final t1 = DateTime(2026, 10, 28, 14, 30);
      final selected = [
        AnonMessageModel(
          id: '1',
          sessionId: 's-1',
          senderAlias: 'Anon',
          messageText: 'Pesan asli',
          createdAt: t1,
          isDeletedForEveryone: true,
        ),
      ];

      final m = selected.first;
      final timeStr = '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}';
      final textContent = m.isDeletedForEveryone ? 'Pesan ini telah ditarik' : m.messageText;
      final result = '[$timeStr] $textContent';

      expect(result.contains('🚫'), false);
      expect(result, '[14:30] Pesan ini telah ditarik');
    });
  });
}
