import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/anonymous_avatar.dart';

void main() {
  group('AnonymousAvatar Widget Tests', () {
    testWidgets('DUPLICATION-003: AnonymousAvatar renders correctly with customizable size and badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnonymousAvatar(size: 48, isOnline: true, showBadge: true),
                AnonymousAvatar(size: 56, isOnline: false, showBadge: false),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 2 avatar containers rendered
      expect(find.byType(AnonymousAvatar), findsNWidgets(2));
    });
  });
}
