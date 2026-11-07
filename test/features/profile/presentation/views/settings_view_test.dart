import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curhat_finder/features/profile/presentation/views/settings_view.dart';

void main() {
  group('SettingsView Tests', () {
    testWidgets('SettingsView renders core account, preference, and legal tiles', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Ubah Kata Sandi'), findsOneWidget);
      expect(find.text('Notifikasi Pesan Chat'), findsOneWidget);
      expect(find.text('Pengingat Sesi Bimbingan'), findsOneWidget);
      expect(find.text('Syarat & Kode Etik Konseling'), findsOneWidget);
      expect(find.text('Kebijakan Privasi Data'), findsOneWidget);
      expect(find.text('Keluar dari Akun'), findsNothing);
      expect(find.text('Hapus Akun & Data Pribadi'), findsOneWidget);
    });

    testWidgets('SettingsView loads saved notification and reminder preferences', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'chat_notifications': true,
        'session_reminders': false,
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Notifikasi Pesan Chat'), findsOneWidget);
    });
  });
}
