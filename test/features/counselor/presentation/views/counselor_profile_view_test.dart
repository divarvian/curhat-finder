import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_profile_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('CounselorProfileView Tests', () {
    testWidgets('CounselorProfileView renders ProfileViewSkeleton when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                const CounselorState(isLoading: true),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorProfileView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ProfileViewSkeleton), findsOneWidget);
    });

    testWidgets('CounselorProfileView renders FileImage when localAvatarPath exists', (tester) async {
      final tempFile = File('${Directory.systemTemp.path}/test_counselor_avatar.png');
      tempFile.writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);

      final counselor = CounselorProfile.empty.copyWith(
        name: 'Dr. Jane Test',
        role: 'Konselor Spesialis',
        email: 'jane@test.com',
        avatarPath: 'assets/images/mascot.png',
        localAvatarPath: tempFile.path,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                CounselorState(
                  isLoading: false,
                  profile: counselor,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorProfileView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (w) => w is Image && w.image is FileImage && (w.image as FileImage).file.path == tempFile.path,
        ),
        findsOneWidget,
      );

      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    });

    testWidgets('CounselorProfileView renders NetworkImage when avatarUrl is set', (tester) async {
      final counselor = CounselorProfile.empty.copyWith(
        name: 'Dr. Jane Remote',
        role: 'Konselor Spesialis',
        email: 'jane@test.com',
        avatarPath: 'assets/images/mascot.png',
        avatarUrl: 'https://example.com/counselor_remote_avatar.png',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                CounselorState(
                  isLoading: false,
                  profile: counselor,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorProfileView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (w) => w is Image && w.image is NetworkImage && (w.image as NetworkImage).url == 'https://example.com/counselor_remote_avatar.png',
        ),
        findsOneWidget,
      );
    });

    testWidgets('CounselorProfileView avatar NetworkImage configures frameBuilder for zero blank flicker', (tester) async {
      final counselor = CounselorProfile.empty.copyWith(
        name: 'Dr. Alena',
        email: 'alena@counselor.ub.ac.id',
        avatarUrl: 'https://example.com/alena_avatar.png',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                CounselorState(
                  isLoading: false,
                  profile: counselor,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorProfileView(),
            ),
          ),
        ),
      );

      await tester.pump();

      final imageFinder = find.byWidgetPredicate(
        (w) => w is Image && w.image is NetworkImage && w.frameBuilder != null,
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('CounselorProfileView renders labels without underline and matches student layout parity', (tester) async {
      final counselor = CounselorProfile.empty.copyWith(
        name: 'Dr. Jane Test',
        role: 'Konselor Sebaya',
        email: 'jane@test.com',
        faculty: 'Fakultas Ilmu Komputer',
        studyProgram: 'Teknik Informatika',
        batchYear: '2023',
        gender: 'Perempuan',
        topics: ['Akademik', 'Burnout'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                CounselorState(
                  isLoading: false,
                  profile: counselor,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorProfileView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no Text widget has TextDecoration.underline
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        expect(text.style?.decoration, isNot(TextDecoration.underline));
      }

      // Verify account info items
      expect(find.text('Fakultas'), findsOneWidget);
      expect(find.text('Prodi'), findsOneWidget);
      expect(find.text('Angkatan'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Topik Keahlian'), findsOneWidget);
      expect(find.text('Akademik'), findsOneWidget);
      expect(find.text('Burnout'), findsOneWidget);
      expect(find.text('Kelola Keahlian'), findsOneWidget);

      // Verify logout button with icon
      expect(find.text('Keluar Akun'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });
  });
}
