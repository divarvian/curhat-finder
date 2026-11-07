import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/chat/data/room_service.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_forum_view.dart';

class FakeRoomService implements RoomService {
  final List<RoomModel> rooms;
  FakeRoomService({this.rooms = const []});

  @override
  Stream<List<RoomModel>> streamRooms({String? category, int limit = 20}) {
    if (category != null && category != 'Semua') {
      return Stream.value(rooms.where((r) => r.category.toLowerCase() == category.toLowerCase()).toList());
    }
    return Stream.value(rooms);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CounselorForumView Tests', () {
    testWidgets('CounselorForumView renders Top Isu Per Fakultas leaderboard matching Forum design', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            roomServiceProvider.overrideWithValue(FakeRoomService()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CounselorForumView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Forum'), findsOneWidget);
      expect(find.text('Top Isu Per Fakultas 🔥'), findsOneWidget);
      expect(find.text('Ilmu Komputer'), findsOneWidget);
      expect(find.text('Teknik'), findsOneWidget);
      expect(find.text('Ekonomi Bisnis'), findsOneWidget);
      expect(find.text('58%'), findsNWidgets(3));
      expect(find.text('Akademik'), findsWidgets);

      // Mulai Diskusi FAB must NOT exist (Counselors only monitor and comment)
      expect(find.text('Mulai Diskusi'), findsNothing);

      // Verify percentage pill text has centered alignment and normalized line height
      final pillText = tester.widget<Text>(find.text('58%').first);
      expect(pillText.textAlign, TextAlign.center);
      expect(pillText.style?.height, 1.0);
    });

    testWidgets('CounselorForumView renders room list when rooms are present', (WidgetTester tester) async {
      final sampleRooms = [
        RoomModel(
          id: 'room-1',
          title: 'Stres Skripsi Semester Akhir',
          content: 'Butuh saran bagaimana mengatur waktu antara revisi dan kerja paruh waktu.',
          category: 'Akademik',
          authorName: 'Anonim 1',
          authorFaculty: 'Fakultas Ilmu Komputer',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          likesCount: 5,
          commentsCount: 3,
        ),
        RoomModel(
          id: 'room-2',
          title: 'Keluarga Menuntut IPK Tinggi',
          content: 'Merasa tertekan dengan ekspektasi orang tua.',
          category: 'Keluarga',
          authorName: 'Anonim 2',
          authorFaculty: 'Fakultas Teknik',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likesCount: 2,
          commentsCount: 1,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            roomServiceProvider.overrideWithValue(FakeRoomService(rooms: sampleRooms)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CounselorForumView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stres Skripsi Semester Akhir'), findsOneWidget);

      // Scroll down to reveal the second room item in the CustomScrollView
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Keluarga Menuntut IPK Tinggi'), findsOneWidget);
      expect(find.text('Mulai Diskusi'), findsNothing);
    });
  });
}
