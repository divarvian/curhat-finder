import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_state.dart';
import 'package:curhat_finder/features/chat/data/room_service.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';
import 'package:curhat_finder/features/chat/presentation/views/room_detail_view.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import '../../../../helpers/fake_notifiers.dart';

class FakeRoomDetailService implements RoomService {
  final List<RoomCommentModel> comments;
  final Function(String, String, String?, String?, String?)? onAddComment;

  FakeRoomDetailService({
    this.comments = const [],
    this.onAddComment,
  });

  @override
  Stream<List<RoomCommentModel>> streamComments(String roomId) {
    return Stream.value(comments);
  }

  @override
  Future<RoomCommentModel?> addComment({
    required String roomId,
    required String content,
    String? authorName,
    String? authorFaculty,
    String? authorRole,
    String? authorTag,
    String? authorAvatarUrl,
  }) async {
    onAddComment?.call(roomId, content, authorName, authorFaculty, authorRole);
    return null;
  }

  @override
  Future<RoomModel?> getRoom(String roomId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RoomDetailView Tests', () {
    final sampleRoom = RoomModel(
      id: 'room-101',
      title: 'Merasa lelah dengan tugas',
      content: 'Banyak deadline bersamaan di akhir semester.',
      category: 'Akademik',
      authorName: 'Mahasiswa UB',
      authorFaculty: 'FILKOM',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      likesCount: 10,
      commentsCount: 2,
    );

    testWidgets('RoomDetailView renders RoomCardSkeleton when room is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(const AuthState()),
            ),
            roomServiceProvider.overrideWithValue(FakeRoomDetailService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RoomDetailView(roomId: 'room-empty'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(RoomCardSkeleton), findsOneWidget);
    });

    testWidgets('RoomDetailView renders counselor verified badge on counselor comments', (WidgetTester tester) async {
      final comments = [
        RoomCommentModel(
          id: 'c-1',
          roomId: 'room-101',
          authorName: 'Dr. Alena',
          authorFaculty: 'FILKOM',
          authorRole: 'konselor',
          content: 'Tarik napas sejenak, kamu sudah berusaha sebaik mungkin.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(const AuthState()),
            ),
            roomServiceProvider.overrideWithValue(FakeRoomDetailService(comments: comments)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RoomDetailView(
                roomId: sampleRoom.id,
                room: sampleRoom,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dr. Alena'), findsOneWidget);
      expect(find.text('Konselor Sebaya'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('Counselor user sees specialized hint and sends comment as counselor role', (WidgetTester tester) async {
      String? sentRole;
      String? sentName;
      String? sentFaculty;

      final fakeService = FakeRoomDetailService(
        comments: const [],
        onAddComment: (roomId, content, name, faculty, role) {
          sentRole = role;
          sentName = name;
          sentFaculty = faculty;
        },
      );

      final counselor = CounselorProfile.empty.copyWith(
        name: 'Konselor Budi',
        faculty: 'Fakultas Ilmu Komputer (FILKOM)',
        role: 'Konselor',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(
                const AuthState(
                  isLoggedIn: true,
                  role: 'konselor',
                  username: 'Konselor Budi',
                ),
              ),
            ),
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                CounselorState(
                  isLoading: false,
                  profile: counselor,
                ),
              ),
            ),
            roomServiceProvider.overrideWithValue(fakeService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RoomDetailView(
                roomId: sampleRoom.id,
                room: sampleRoom,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify hint text for counselor
      expect(find.text('Tulis tanggapan atau bimbingan konselor...'), findsOneWidget);

      // Enter comment and submit
      await tester.enterText(find.byType(TextField), 'Semangat ya, kamu pasti bisa!');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(sentRole, 'konselor');
      expect(sentName, 'Konselor Budi');
      expect(sentFaculty, 'FILKOM');
    });

    testWidgets('RoomDetailView renders comment with AppAvatar', (WidgetTester tester) async {
      final comments = [
        RoomCommentModel(
          id: 'c-2',
          roomId: 'room-101',
          authorName: 'Budi Santoso',
          authorFaculty: 'FILKOM',
          authorAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'Komentar dengan avatar pengguna.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(const AuthState()),
            ),
            roomServiceProvider.overrideWithValue(FakeRoomDetailService(comments: comments)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RoomDetailView(
                roomId: sampleRoom.id,
                room: sampleRoom,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Komentar dengan avatar pengguna.'), findsOneWidget);
    });

    testWidgets('RoomDetailView displays newest comments at the top', (WidgetTester tester) async {
      final olderComment = RoomCommentModel(
        id: 'c-old',
        roomId: 'room-101',
        authorName: 'User Lama',
        content: 'Komentar yang lama',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      final newerComment = RoomCommentModel(
        id: 'c-new',
        roomId: 'room-101',
        authorName: 'User Baru',
        content: 'Komentar yang lebih baru',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(const AuthState()),
            ),
            roomServiceProvider.overrideWithValue(FakeRoomDetailService(comments: [olderComment, newerComment])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RoomDetailView(
                roomId: sampleRoom.id,
                room: sampleRoom,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final newerFinder = find.text('Komentar yang lebih baru');
      final olderFinder = find.text('Komentar yang lama');

      expect(newerFinder, findsOneWidget);
      expect(olderFinder, findsOneWidget);

      final newerY = tester.getTopLeft(newerFinder).dy;
      final olderY = tester.getTopLeft(olderFinder).dy;

      expect(newerY < olderY, isTrue);
    });
  });
}
