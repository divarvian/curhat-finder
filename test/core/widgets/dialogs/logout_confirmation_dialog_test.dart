import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/dialogs/logout_confirmation_dialog.dart';

void main() {
  group('LogoutConfirmationDialog Widget Tests', () {
    testWidgets('LogoutConfirmationDialog displays Milo mascot, title, and buttons properly', (tester) async {
      bool? confirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  confirmed = await LogoutConfirmationDialog.show(context);
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Keluar Akun?'), findsOneWidget);
      expect(find.text('Apakah kamu yakin ingin keluar? Sesi dan riwayatmu akan tetap tersimpan saat kamu masuk kembali.'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(confirmed, isFalse);

      // Re-open and tap Keluar
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });
  });
}
