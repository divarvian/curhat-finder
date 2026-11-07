import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/features/beranda/domain/tip_model.dart';
import 'package:curhat_finder/features/beranda/presentation/views/tip_detail_view.dart';

void main() {
  group('TipDetailView Tests', () {
    testWidgets('TipDetailView renders canonical When Yh tip, steps, interactions, and mascot_seek.png', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TipDetailView(),
          ),
        ),
      );
      await tester.pump();

      // 1. Check title and tags
      expect(find.text('Tips mengatasi perasaan\nwhen yh berlebih'), findsOneWidget);
      expect(find.text('Kak Sekar • Afirmasi'), findsOneWidget);
      expect(find.text('1 hari lalu'), findsOneWidget);

      // 2. Check steps title and content
      expect(find.text('Langkah Nyata Mengurangi Frekuensi "When Yh":'), findsOneWidget);

      // 3. Check like & bookmark initial widgets
      expect(find.text('99999'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);

      // 4. Check mascot_seek.png presence
      final imageFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/mascot_seek.png',
      );
      expect(imageFinder, findsOneWidget);

      // 5. Verify mascot is sticky/fixed at bottom of card with IgnorePointer
      final positionedMascot = find.ancestor(
        of: imageFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Positioned && widget.bottom == 0,
        ),
      );
      expect(positionedMascot, findsOneWidget);
      expect(
        find.ancestor(
          of: imageFinder,
          matching: find.byWidgetPredicate((widget) => widget is IgnorePointer && widget.ignoring),
        ),
        findsOneWidget,
      );
    });

    testWidgets('TipDetailView with custom community TipModel renders author, category, and action buttons', (tester) async {
      final customTip = TipModel(
        id: 'tip-custom-1',
        authorName: 'Budi Santoso',
        authorFaculty: 'FT',
        authorGender: 'Laki-laki',
        category: 'Productivity',
        content: 'Cobalah teknik Pomodoro 25 menit fokus dan 5 menit istirahat.',
        likesCount: 42,
        bookmarksCount: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TipDetailView(tip: customTip),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Budi Santoso • Productivity'), findsOneWidget);
      expect(find.text('2 jam lalu'), findsOneWidget);
      expect(find.textContaining('Pomodoro'), findsNWidgets(2)); // matches title and intro
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);

      // Verify mascot_seek.png is also present
      final imageFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/mascot_seek.png',
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('TipDetailView like and bookmark buttons toggle state upon tap', (tester) async {
      final customTip = TipModel(
        id: 'tip-custom-2',
        authorName: 'Sekar',
        authorFaculty: 'FIB',
        authorGender: 'Perempuan',
        category: 'Self-care',
        content: 'Minum air hangat di pagi hari bikin tubuh lebih segar.',
        likesCount: 10,
        bookmarksCount: 3,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TipDetailView(tip: customTip),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);

      // Tap like button
      final likeBtn = find.byIcon(Icons.favorite_border_rounded);
      expect(likeBtn, findsOneWidget);
      await tester.tap(likeBtn);
      await tester.pump();

      expect(find.text('11'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Tap bookmark button
      final bookmarkBtn = find.text('Simpan');
      await tester.tap(bookmarkBtn);
      await tester.pump();

      expect(find.text('Tersimpan'), findsOneWidget);
    });

    testWidgets('TipDetailView displays "Hapus Tips" when current user is owner', (tester) async {
      SupabaseService.mockUserId = 'detail-owner-123';

      final tip = TipModel(
        id: 'tip-detail-test',
        userId: 'detail-owner-123',
        authorName: 'Saya',
        authorFaculty: 'FILKOM',
        authorGender: 'Perempuan',
        category: 'Self-care',
        title: 'Tips Istirahat Sejenak',
        content: 'Pentingnya tidur cukup minimal 7 jam sehari.',
        likesCount: 10,
        bookmarksCount: 4,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TipDetailView(tip: tip),
          ),
        ),
      );

      await tester.pump();

      // Tap more_horiz_rounded icon button in AppBar
      final moreIconFinder = find.byIcon(Icons.more_horiz_rounded);
      expect(moreIconFinder, findsOneWidget);
      await tester.tap(moreIconFinder);
      await tester.pumpAndSettle();

      // Owner sees "Hapus Tips" and "Bagikan Tips", but NOT "Laporkan Konten"
      expect(find.text('Hapus Tips'), findsOneWidget);
      expect(find.text('Bagikan Tips'), findsOneWidget);
      expect(find.text('Laporkan Konten'), findsNothing);

      SupabaseService.mockUserId = null;
    });
  });
}
