import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';

void main() {
  group('RoomModel & RoomCommentModel Tests', () {
    test('RoomModel parses structured authorName, authorFaculty, authorGender and formats authorTag', () {
      final room = RoomModel(
        id: 'room-structured-1',
        authorName: 'Dinda',
        authorFaculty: 'FILKOM',
        authorGender: 'Perempuan',
        category: 'Kesepian',
        title: 'Curhat Malam',
        content: 'Isi curhat santai.',
        createdAt: DateTime.now(),
      );

      expect(room.authorName, 'Dinda');
      expect(room.authorFaculty, 'FILKOM');
      expect(room.authorGender, 'Perempuan');
      expect(room.authorTag, 'Dinda • FILKOM');
    });

    test('RoomCommentModel differentiates counselor and peer role with isCounselor getter', () {
      final peerComment = RoomCommentModel(
        id: 'c-peer-1',
        roomId: 'r-1',
        authorName: 'Kak Sekar',
        authorFaculty: 'FIB',
        authorRole: 'mahasiswa',
        content: 'Semangat ya!',
        createdAt: DateTime.now(),
      );

      final counselorComment = RoomCommentModel(
        id: 'c-counselor-1',
        roomId: 'r-1',
        authorName: 'Kak Dodo',
        authorFaculty: 'Pusat Konseling',
        authorRole: 'konselor',
        content: 'Tarik napas dalam-dalam.',
        createdAt: DateTime.now(),
      );

      expect(peerComment.isCounselor, false);
      expect(peerComment.authorTag, 'Kak Sekar • FIB');

      expect(counselorComment.isCounselor, true);
      expect(counselorComment.authorTag, 'Kak Dodo (Konselor Sebaya)');
    });
  });
}
