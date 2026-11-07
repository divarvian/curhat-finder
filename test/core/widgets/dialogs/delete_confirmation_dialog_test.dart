import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/widgets/dialogs/delete_confirmation_dialog.dart';

void main() {
  group('DeleteConfirmationDialog Widget Tests', () {
    testWidgets('DeleteConfirmationDialog renders Milo mascot, title, message and triggers onConfirmDelete', (tester) async {
      bool deleteConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeleteConfirmationDialog(
              title: 'Hapus Curhat Ini?',
              message: 'Curhat yang sudah dihapus tidak dapat dipulihkan kembali.',
              onConfirmDelete: () {
                deleteConfirmed = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Hapus Curhat Ini?'), findsOneWidget);
      expect(find.text('Curhat yang sudah dihapus tidak dapat dipulihkan kembali.'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == 'assets/images/mascot_leave.png',
        ),
        findsOneWidget,
      );

      // Tap Hapus button
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(deleteConfirmed, isTrue);
    });
  });
}
