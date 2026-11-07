import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/cards/interactive_room_card.dart';

void main() {
  group('InteractiveRoomCard Widget Tests', () {
    testWidgets('DUPLICATION-002: InteractiveRoomCard renders as detail header and handles onBackTap', (WidgetTester tester) async {
      bool backTapped = false;
      bool cardTapped = false;

      final dummyRoom = RoomModel(
        id: 'room-test-1',
        authorName: 'Anonim',
        authorFaculty: 'FILKOM',
        category: 'Akademik',
        title: 'Ujian Akhir Semester Bingung',
        content: 'Ada yang tahu kisi-kisi matkul ini ga ya? Perlu sharing santai.',
        likesCount: 5,
        commentsCount: 3,
        bookmarksCount: 2,
        createdAt: DateTime.now(),
      );

      // Test with isDetailHeader = true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveRoomCard(
              room: dummyRoom,
              initialIsLiked: false,
              initialIsBookmarked: false,
              onToggleLike: (id, val) {},
              onToggleBookmark: (id, val) {},
              isDetailHeader: true,
              onBackTap: () => backTapped = true,
              onTap: (_) => cardTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Ujian Akhir Semester Bingung'), findsOneWidget);
      expect(find.text('Anonim • FILKOM'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(backTapped, isTrue);

      // Tap card body does not invoke onTap in detail mode
      await tester.tap(find.text('Ujian Akhir Semester Bingung'));
      await tester.pumpAndSettle();
      expect(cardTapped, isFalse);

      // Test with isDetailHeader = false (feed mode)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveRoomCard(
              room: dummyRoom,
              initialIsLiked: false,
              initialIsBookmarked: false,
              onToggleLike: (id, val) {},
              onToggleBookmark: (id, val) {},
              isDetailHeader: false,
              onTap: (_) => cardTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      await tester.tap(find.text('Ujian Akhir Semester Bingung'));
      await tester.pumpAndSettle();
      expect(cardTapped, isTrue);
    });

    testWidgets('InteractiveRoomCard displays "Hapus Curhat" when current user is owner', (tester) async {
      SupabaseService.mockUserId = 'owner-user-123';

      final room = RoomModel(
        id: 'room-owner-test',
        userId: 'owner-user-123',
        authorName: 'Pemilik',
        authorFaculty: 'FILKOM',
        category: 'Akademik',
        title: 'Curhat Milik Saya',
        content: 'Ini adalah curhat pribadi saya yang bisa saya hapus.',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractiveRoomCard(
                room: room,
                initialIsLiked: false,
                initialIsBookmarked: false,
                onToggleLike: (roomId, isLiked) {},
                onToggleBookmark: (roomId, isBookmarked) {},
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap 3-dots icon
      final moreIconFinder = find.byIcon(Icons.more_horiz);
      expect(moreIconFinder, findsOneWidget);
      await tester.tap(moreIconFinder);
      await tester.pumpAndSettle();

      // Owner sees "Hapus Curhat" and "Bagikan Curhat", but NOT "Laporkan Konten"
      expect(find.text('Hapus Curhat'), findsOneWidget);
      expect(find.text('Bagikan Curhat'), findsOneWidget);
      expect(find.text('Laporkan Konten'), findsNothing);

      SupabaseService.mockUserId = null;
    });

    testWidgets('InteractiveRoomCard does NOT display "Hapus Curhat" when current user is not owner', (tester) async {
      SupabaseService.mockUserId = 'another-user-456';

      final room = RoomModel(
        id: 'room-other-test',
        userId: 'original-author-789',
        authorName: 'Mahasiswa Lain',
        authorFaculty: 'FEB',
        category: 'Keuangan',
        title: 'Curhat Orang Lain',
        content: 'Ini adalah curhat orang lain yang tidak boleh saya hapus.',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractiveRoomCard(
                room: room,
                initialIsLiked: false,
                initialIsBookmarked: false,
                onToggleLike: (roomId, isLiked) {},
                onToggleBookmark: (roomId, isBookmarked) {},
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap 3-dots icon
      final moreIconFinder = find.byIcon(Icons.more_horiz);
      expect(moreIconFinder, findsOneWidget);
      await tester.tap(moreIconFinder);
      await tester.pumpAndSettle();

      // Non-owner does NOT see "Hapus Curhat", only "Bagikan Curhat" and "Laporkan Konten"
      expect(find.text('Hapus Curhat'), findsNothing);
      expect(find.text('Bagikan Curhat'), findsOneWidget);
      expect(find.text('Laporkan Konten'), findsOneWidget);

      SupabaseService.mockUserId = null;
    });
  });
}
