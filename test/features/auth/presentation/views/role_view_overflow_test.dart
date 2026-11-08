import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/auth/presentation/views/role_view.dart';

void main() {
  group('RoleView Overflow & Responsiveness Tests', () {
    testWidgets('RoleView renders without overflow on standard viewport', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoleView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kamu disini sebagai?'), findsOneWidget);
      expect(find.text('Aku Mahasiswa'), findsOneWidget);
      expect(find.text('Aku Konselor'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RoleView does not overflow when keyboard opens (simulated viewInsets bottom)', (tester) async {
      // Simulate typical mobile screen (e.g. 390 x 844)
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;

      // Simulate keyboard open by setting bottom viewInsets (350dp)
      tester.view.viewInsets = const FakeViewPadding(bottom: 350 * 2);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoleView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No RenderFlex overflow exception should occur
      expect(tester.takeException(), isNull);

      // Verify user can interact and select roles
      await tester.tap(find.text('Aku Mahasiswa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aku Konselor'));
      await tester.pumpAndSettle();

      // No exception thrown during interaction
      expect(tester.takeException(), isNull);
    });
  });
}
