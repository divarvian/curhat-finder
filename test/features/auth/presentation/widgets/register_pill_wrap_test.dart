import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/auth/presentation/widgets/register_steps/register_step_template.dart';

void main() {
  group('RegisterPillOption Layout & Wrap Tests', () {
    testWidgets('RegisterPillOption shrink-wraps and arranges horizontally in a Wrap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    RegisterPillOption(
                      label: 'FILKOM',
                      isSelected: false,
                      onTap: () {},
                    ),
                    RegisterPillOption(
                      label: 'FT',
                      isSelected: true,
                      onTap: () {},
                    ),
                    RegisterPillOption(
                      label: 'FEB',
                      isSelected: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Find the pill widgets
      final filkomFinder = find.widgetWithText(RegisterPillOption, 'FILKOM');
      final ftFinder = find.widgetWithText(RegisterPillOption, 'FT');
      final febFinder = find.widgetWithText(RegisterPillOption, 'FEB');

      expect(filkomFinder, findsOneWidget);
      expect(ftFinder, findsOneWidget);
      expect(febFinder, findsOneWidget);

      final filkomSize = tester.getSize(filkomFinder);
      final ftSize = tester.getSize(ftFinder);
      final febSize = tester.getSize(febFinder);

      // Verify pills do not stretch to 400px (not full width)
      expect(filkomSize.width, lessThan(150));
      expect(ftSize.width, lessThan(150));
      expect(febSize.width, lessThan(150));

      final filkomPos = tester.getTopLeft(filkomFinder);
      final ftPos = tester.getTopLeft(ftFinder);
      final febPos = tester.getTopLeft(febFinder);

      // Verify they are on the same horizontal row (same Y coordinate)
      expect(ftPos.dy, equals(filkomPos.dy));
      expect(febPos.dy, equals(filkomPos.dy));

      // Verify they are horizontally arranged in order: filkom < ft < feb
      expect(ftPos.dx, greaterThan(filkomPos.dx));
      expect(febPos.dx, greaterThan(ftPos.dx));
    });

    testWidgets('RegisterPillOption wraps to the next line when width exceeds parent width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200, // Small width to force wrapping
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    RegisterPillOption(
                      label: 'Fakultas Ilmu Komputer',
                      isSelected: false,
                      onTap: () {},
                    ),
                    RegisterPillOption(
                      label: 'Fakultas Teknik',
                      isSelected: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final pill1Finder = find.widgetWithText(RegisterPillOption, 'Fakultas Ilmu Komputer');
      final pill2Finder = find.widgetWithText(RegisterPillOption, 'Fakultas Teknik');

      final pill1Pos = tester.getTopLeft(pill1Finder);
      final pill2Pos = tester.getTopLeft(pill2Finder);

      // Since width 200 cannot fit both, pill2 wraps to the next line (greater dy)
      expect(pill2Pos.dy, greaterThan(pill1Pos.dy));
    });
  });
}
