import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/app_avatar.dart';

void main() {
  group('AppAvatar Widget Tests', () {
    testWidgets('Renders fallback asset when imageUrl and localPath are null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar(
              size: 56,
              fallbackAsset: 'assets/images/profile.png',
            ),
          ),
        ),
      );

      expect(find.byType(AppAvatar), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/profile.png');
    });

    testWidgets('Renders online badge when showOnlineBadge is true and isOnline is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar(
              size: 52,
              isOnline: true,
              showOnlineBadge: true,
              badgeColor: Color(0xFF00E676),
            ),
          ),
        ),
      );

      expect(find.byType(AppAvatar), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);

      // Verify presence of badge container
      final containers = tester.widgetList<Container>(find.byType(Container));
      final badgeContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == const Color(0xFF00E676),
      );
      expect(badgeContainer, isNotNull);
    });

    testWidgets('Does not render online badge when isOnline is false even if showOnlineBadge is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar(
              size: 52,
              isOnline: false,
              showOnlineBadge: true,
            ),
          ),
        ),
      );

      expect(find.byType(AppAvatar), findsOneWidget);
      // No green badge container
      final containers = tester.widgetList<Container>(find.byType(Container));
      final badgeContainers = containers.where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == const Color(0xFF00E676),
      );
      expect(badgeContainers.isEmpty, isTrue);
    });

    testWidgets('Renders custom size and custom border correctly', (WidgetTester tester) async {
      final customBorder = Border.all(color: Colors.red, width: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAvatar(
              size: 80,
              border: customBorder,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppAvatar),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth ?? 80, 80);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.border, equals(customBorder));
    });
  });
}
