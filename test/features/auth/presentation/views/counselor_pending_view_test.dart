import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_state.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:curhat_finder/features/auth/presentation/views/counselor_pending_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('Counselor Approval Gate & Verification Tests', () {
    test('AuthState defaults and verification flag behaves correctly for roles', () {
      const studentState = AuthState(
        isLoggedIn: true,
        role: 'mahasiswa',
        isVerified: true,
        counselorStatus: 'approved',
      );
      expect(studentState.isVerified, isTrue);
      expect(studentState.counselorStatus, 'approved');

      const pendingCounselorState = AuthState(
        isLoggedIn: true,
        role: 'konselor',
        isVerified: false,
        counselorStatus: 'pending',
      );
      expect(pendingCounselorState.isVerified, isFalse);
      expect(pendingCounselorState.counselorStatus, 'pending');

      final approvedCounselorState = pendingCounselorState.copyWith(
        isVerified: true,
        counselorStatus: 'approved',
      );
      expect(approvedCounselorState.isVerified, isTrue);
      expect(approvedCounselorState.counselorStatus, 'approved');
    });

    testWidgets('CounselorPendingView renders pending message, status badge, and check button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(
                const AuthState(
                  isLoggedIn: true,
                  username: 'Kak Alena',
                  email: 'alena@counselor.ub.ac.id',
                  role: 'konselor',
                  isVerified: false,
                  counselorStatus: 'pending',
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: CounselorPendingView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Akun Konselor Sedang Ditinjau'), findsOneWidget);
      expect(find.textContaining('Pendaftaran akun Konselor Sebaya kamu sedang ditinjau'), findsOneWidget);
      expect(find.text('Menunggu Verifikasi'), findsOneWidget);
      expect(find.text('Cek Status Verifikasi'), findsOneWidget);
      expect(find.text('Keluar / Ganti Akun'), findsOneWidget);
    });

    testWidgets('CounselorPendingView invokes refreshProfile silently on mount', (WidgetTester tester) async {
      bool refreshCalled = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuthNotifier(
                const AuthState(
                  isLoggedIn: true,
                  username: 'Kak Alena',
                  email: 'alena@counselor.ub.ac.id',
                  role: 'konselor',
                  isVerified: false,
                  counselorStatus: 'pending',
                ),
                onRefresh: () {
                  refreshCalled = true;
                },
              ),
            ),
          ],
          child: const MaterialApp(
            home: CounselorPendingView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(refreshCalled, isTrue);
    });

    test('AuthNotifier static cache holds verified state and supports router decisions', () {
      AuthNotifier.lastKnownRole = 'konselor';
      AuthNotifier.lastKnownIsVerified = true;

      expect(AuthNotifier.lastKnownRole, 'konselor');
      expect(AuthNotifier.lastKnownIsVerified, isTrue);
    });
  });
}
