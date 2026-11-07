import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';
import 'package:curhat_finder/features/chat/presentation/providers/rooms_interaction_provider.dart';

void main() {
  group('RoomsInteractionState Tests', () {
    test('RoomsInteractionState manages optimistic rooms accurately', () {
      const initialState = RoomsInteractionState();
      expect(initialState.optimisticRooms, isEmpty);

      final testRoom = RoomModel(
        id: 'opt-room-1',
        title: 'Optimistic Room Test',
        content: 'Test content',
        category: 'Kuliah & Karir',
        authorName: 'Arvian',
        authorFaculty: 'FILKOM',
        authorGender: 'Laki-laki',
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      final stateWithRoom = initialState.copyWith(optimisticRooms: [testRoom]);
      expect(stateWithRoom.optimisticRooms.length, 1);
      expect(stateWithRoom.optimisticRooms.first.id, 'opt-room-1');

      final stateEmpty = stateWithRoom.copyWith(optimisticRooms: []);
      expect(stateEmpty.optimisticRooms, isEmpty);
    });
  });
}
