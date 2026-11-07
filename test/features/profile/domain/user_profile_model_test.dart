import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/profile/domain/user_profile_model.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';

void main() {
  group('UserProfile & CounselorProfile Model Tests', () {
    test('UserProfile and CounselorProfile model support avatarUrl and copyWith', () {
      final user = UserProfile.empty().copyWith(
        name: 'Budi',
        email: 'budi@test.com',
        role: 'Mahasiswa',
        faculty: 'FILKOM',
        studyProgram: 'TIF',
        avatarPath: 'assets/images/profile.png',
        avatarUrl: 'https://supabase.co/storage/v1/object/public/avatars/u1/avatar_100.png',
        localAvatarPath: '/tmp/local_avatar.png',
      );

      expect(user.avatarUrl, 'https://supabase.co/storage/v1/object/public/avatars/u1/avatar_100.png');
      expect(user.localAvatarPath, '/tmp/local_avatar.png');

      final updatedUser = user.copyWith(
        avatarUrl: 'https://supabase.co/storage/v1/object/public/avatars/u1/avatar_200.png',
      );
      expect(updatedUser.avatarUrl, 'https://supabase.co/storage/v1/object/public/avatars/u1/avatar_200.png');
      expect(updatedUser.localAvatarPath, '/tmp/local_avatar.png');

      final counselor = CounselorProfile.empty.copyWith(
        name: 'Dr. Jane',
        role: 'Konselor',
        email: 'jane@test.com',
        avatarPath: 'assets/images/mascot.png',
        avatarUrl: 'https://supabase.co/storage/v1/object/public/avatars/c1/avatar_300.png',
        localAvatarPath: '/tmp/counselor_avatar.png',
      );

      expect(counselor.avatarUrl, 'https://supabase.co/storage/v1/object/public/avatars/c1/avatar_300.png');
      expect(counselor.localAvatarPath, '/tmp/counselor_avatar.png');

      final updatedCounselor = counselor.copyWith(
        avatarUrl: 'https://supabase.co/storage/v1/object/public/avatars/c1/avatar_400.png',
      );
      expect(updatedCounselor.avatarUrl, 'https://supabase.co/storage/v1/object/public/avatars/c1/avatar_400.png');
    });
  });
}
