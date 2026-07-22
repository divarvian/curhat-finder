import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/user_profile_model.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // Return dummy data
    return UserProfile(
      name: 'Whisky ✨',
      role: 'Mahasiswa',
      email: 'whisky@student.ub.ac.id',
      faculty: 'FILKOM',
      studyProgram: 'TIF',
      batchYear: '2025',
      gender: 'Perempuan',
      hobby: 'Memasak',
      avatarPath: 'assets/images/mascot.png', // Temporary fallback avatar
    );
  }

  // Future function to update profile
  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }

  void updateAvatar(String imagePath) {
    state = UserProfile(
      name: state.name,
      role: state.role,
      email: state.email,
      faculty: state.faculty,
      studyProgram: state.studyProgram,
      batchYear: state.batchYear,
      gender: state.gender,
      hobby: state.hobby,
      avatarPath: state.avatarPath, // Keep fallback
      localAvatarPath: imagePath,   // New picked image
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});
