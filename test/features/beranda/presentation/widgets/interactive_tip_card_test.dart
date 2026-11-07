import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/features/beranda/domain/tip_model.dart';
import 'package:curhat_finder/features/beranda/presentation/widgets/interactive_tip_card.dart';

void main() {
  group('InteractiveTipCard Widget Tests', () {
    testWidgets('InteractiveTipCard renders both bold title and description matching Tips.png', (tester) async {
      final tipWithTitle = TipModel(
        id: 'tip-3',
        authorName: 'Kak Cris',
        authorFaculty: 'FK',
        authorGender: 'Perempuan',
        category: 'Self-care',
        title: 'Tips jaga hidrasi diri lewat air putih',
        content: 'Selalu pesan air putih dingin dan tetap terhidrasi sepanjang hari.',
        likesCount: 15,
        bookmarksCount: 5,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveTipCard(
              item: tipWithTitle,
              initialIsLiked: false,
              initialIsBookmarked: false,
              onToggleLike: (_) async => true,
              onToggleBookmark: (_) async => true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tips jaga hidrasi diri lewat air putih'), findsOneWidget);
      expect(find.text('Selalu pesan air putih dingin dan tetap terhidrasi sepanjang hari.'), findsOneWidget);
    });

    testWidgets('InteractiveTipCard displays "Hapus Tips" when current user is owner', (tester) async {
      SupabaseService.mockUserId = 'tip-owner-123';

      final tip = TipModel(
        id: 'tip-owner-test',
        userId: 'tip-owner-123',
        authorName: 'Saya',
        authorFaculty: 'FILKOM',
        authorGender: 'Laki-laki',
        category: 'Productivity',
        title: 'Tips Sukses Ujian',
        content: 'Belajar dengan konsisten setiap hari 30 menit.',
        likesCount: 5,
        bookmarksCount: 2,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractiveTipCard(
                item: tip,
                initialIsLiked: false,
                initialIsBookmarked: false,
                onToggleLike: (_) async => true,
                onToggleBookmark: (_) async => true,
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

      // Owner sees "Hapus Tips" and "Bagikan Tips", but NOT "Laporkan Konten"
      expect(find.text('Hapus Tips'), findsOneWidget);
      expect(find.text('Bagikan Tips'), findsOneWidget);
      expect(find.text('Laporkan Konten'), findsNothing);

      SupabaseService.mockUserId = null;
    });

    testWidgets('Fase 1: InteractiveTipCard renders author, category, and interaction buttons', (WidgetTester tester) async {
      final tip = TipModel(
        id: 'tip-101',
        content: 'Cobalah teknik Pomodoro 25 menit fokus dan 5 menit istirahat.',
        category: 'Productivity',
        authorName: 'Kak Sekar',
        authorFaculty: 'FILKOM',
        authorGender: 'Perempuan',
        likesCount: 42,
        bookmarksCount: 15,
        createdAt: DateTime.now(),
      );

      bool likeTapped = false;
      bool bookmarkTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveTipCard(
              item: tip,
              initialIsLiked: false,
              initialIsBookmarked: true,
              onToggleLike: (id) async {
                likeTapped = true;
                return true;
              },
              onToggleBookmark: (id) async {
                bookmarkTapped = true;
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Kak Sekar'), findsOneWidget);
      expect(find.textContaining('Productivity'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Tersimpan'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likeTapped, isTrue);

      await tester.tap(find.byIcon(Icons.bookmark));
      expect(bookmarkTapped, isTrue);
    });
  });
}
