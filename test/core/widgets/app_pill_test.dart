import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/app_pill.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';

void main() {
  group('AppPill Widget Tests', () {
    testWidgets('renders label with optical centering and default unselected styles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPill(label: 'Akademik'),
          ),
        ),
      );

      final textFinder = find.text('Akademik');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.strutStyle?.forceStrutHeight, isTrue);
      expect(textWidget.strutStyle?.height, 1.0);
      expect(textWidget.style?.height, 1.0);
      expect(textWidget.style?.color, AppColors.twilightDark);
    });

    testWidgets('renders selected styles when isSelected is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPill(label: 'Akademik', isSelected: true),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Akademik'));
      expect(textWidget.style?.color, AppColors.twilightDarker);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPill(
              label: 'Tap Me',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders leading and trailing widgets properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPill(
              label: 'Verified',
              leading: Icon(Icons.check, key: Key('leading-icon')),
              trailing: Icon(Icons.close, key: Key('trailing-icon')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('leading-icon')), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byKey(const Key('trailing-icon')), findsOneWidget);
    });
  });
}
