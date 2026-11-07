import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_state.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:curhat_finder/features/profile/domain/user_profile_model.dart';
import 'package:curhat_finder/features/profile/presentation/providers/profile_provider.dart';
import 'package:curhat_finder/features/profile/presentation/views/profile_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('ProfileView Tests', () {
    testWidgets('ProfileView renders ProfileViewSkeleton without showing dummy Whisky data when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(
              () => FakeProfileNotifier(
                UserProfile.empty(isLoading: true),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ProfileViewSkeleton), findsOneWidget);
      expect(find.text('Whisky ✨'), findsNothing);
    });

    testWidgets('ProfileView renders FileImage when localAvatarPath points to existing file', (tester) async {
      final tempFile = File('${Directory.systemTemp.path}/test_user_avatar.png');
      tempFile.writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);

      final user = UserProfile.empty(isLoading: false).copyWith(
        name: 'Budi Test',
        localAvatarPath: tempFile.path,
        avatarUrl: 'https://example.com/remote.png',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => FakeProfileNotifier(user)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileView(),
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

    testWidgets('ProfileView renders NetworkImage when avatarUrl is present and no local file exists', (tester) async {
      final user = UserProfile.empty(isLoading: false).copyWith(
        name: 'Budi Network',
        localAvatarPath: null,
        avatarUrl: 'https://example.com/remote_avatar_123.png',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => FakeProfileNotifier(user)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (w) => w is Image && w.image is NetworkImage && (w.image as NetworkImage).url == 'https://example.com/remote_avatar_123.png',
        ),
        findsOneWidget,
      );
    });

    testWidgets('ProfileView avatar NetworkImage configures frameBuilder for zero blank flicker', (tester) async {
      final user = UserProfile.empty(isLoading: false).copyWith(
        name: 'Budi Test',
        email: 'budi@ub.ac.id',
        avatarUrl: 'https://example.com/budi_avatar.png',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => FakeProfileNotifier(user)),
            authProvider.overrideWith(
              () => FakeAuthNotifier(
                const AuthState(isLoggedIn: true, username: 'Budi Test', email: 'budi@ub.ac.id'),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileView(),
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
  });
}
