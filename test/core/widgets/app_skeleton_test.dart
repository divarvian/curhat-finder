import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';

void main() {
  group('AppSkeleton Widget Tests', () {
    testWidgets('All Skeleton components render without throwing exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TipCardSkeleton(),
                  RoomCardSkeleton(),
                  CommentCardSkeleton(),
                  JurnalHistorySkeleton(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TipCardSkeleton), findsOneWidget);
      expect(find.byType(RoomCardSkeleton), findsOneWidget);
      expect(find.byType(CommentCardSkeleton), findsOneWidget);
      expect(find.byType(JurnalHistorySkeleton), findsOneWidget);
      expect(find.byType(AppShimmer), findsNWidgets(4));
    });

    testWidgets('ChatBubbleSkeleton and CounselorCardSkeleton render without throwing exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: ChatBubbleSkeleton()),
                CounselorCardSkeleton(),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ChatBubbleSkeleton), findsOneWidget);
      expect(find.byType(CounselorCardSkeleton), findsOneWidget);
      expect(find.byType(AppShimmer), findsNWidgets(2));
    });

    testWidgets('PresenceStatusCardSkeleton, CounselorStatsSkeleton, and CounselorForumCardSkeleton render properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PresenceStatusCardSkeleton(),
                  CounselorStatsSkeleton(),
                  CounselorForumCardSkeleton(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(PresenceStatusCardSkeleton), findsOneWidget);
      expect(find.byType(CounselorStatsSkeleton), findsOneWidget);
      expect(find.byType(CounselorForumCardSkeleton), findsOneWidget);
      expect(find.byType(AppShimmer), findsNWidgets(3));
    });
  });
}
