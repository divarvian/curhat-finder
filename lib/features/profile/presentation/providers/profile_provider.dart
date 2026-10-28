import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/academic_helper.dart';
import '../../domain/user_profile_model.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final defaultProfile = UserProfile(
      name: 'Whisky ✨',
      role: 'Mahasiswa',
      email: 'whisky@student.ub.ac.id',
      faculty: 'FILKOM',
      studyProgram: 'S1 Teknik Informatika',
      batchYear: '2025',
      gender: 'Perempuan',
      hobby: 'Memasak',
      avatarPath: 'assets/images/mascot.png',
    );

    Future.microtask(() => reloadProfile());
    return defaultProfile;
  }

  Future<void> reloadProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        final rawFaculty = (data['faculty'] as String?) ?? state.faculty;
        final rawProdi = (data['study_program'] as String?) ?? state.studyProgram;
        final resolvedFaculty = AcademicHelper.resolveFaculty(rawFaculty);
        final resolvedProdi = AcademicHelper.resolveProdi(rawProdi);

        final hobbies = (data['hobbies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        state = UserProfile(
          name: data['nickname'] ?? data['full_name'] ?? state.name,
          role: data['role'] == 'konselor' ? 'Konselor' : 'Mahasiswa',
          email: SupabaseService.currentUser?.email ?? state.email,
          faculty: resolvedFaculty,
          studyProgram: resolvedProdi,
          batchYear: data['batch_year'] ?? state.batchYear,
          gender: data['gender'] ?? state.gender,
          hobby: hobbies.isNotEmpty ? hobbies.join(', ') : state.hobby,
          avatarPath: state.avatarPath,
          localAvatarPath: data['avatar_url'] as String?,
        );

        // Auto-migrasi ke Supabase jika sebelumnya tersimpan kode numerik
        if (resolvedFaculty != rawFaculty || resolvedProdi != rawProdi) {
          SupabaseService.client.from('profiles').update({
            'faculty': resolvedFaculty,
            'study_program': resolvedProdi,
          }).eq('id', userId);
        }
      }
    } catch (_) {}
  }

  Future<void> uploadAvatar(XFile file) async {
    final userId = SupabaseService.currentUserId;

    state = UserProfile(
      name: state.name,
      role: state.role,
      email: state.email,
      faculty: state.faculty,
      studyProgram: state.studyProgram,
      batchYear: state.batchYear,
      gender: state.gender,
      hobby: state.hobby,
      avatarPath: state.avatarPath,
      localAvatarPath: file.path,
    );

    if (userId != null) {
      final storage = StorageService();
      final publicUrl = await storage.uploadAvatar(file: file, userId: userId);
      if (publicUrl != null) {
        state = UserProfile(
          name: state.name,
          role: state.role,
          email: state.email,
          faculty: state.faculty,
          studyProgram: state.studyProgram,
          batchYear: state.batchYear,
          gender: state.gender,
          hobby: state.hobby,
          avatarPath: state.avatarPath,
          localAvatarPath: publicUrl,
        );
      }
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    state = newProfile;
    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      try {
        final hobbiesList = newProfile.hobby
            .split(',')
            .map((h) => h.trim())
            .where((h) => h.isNotEmpty)
            .toList();

        await SupabaseService.client.from('profiles').update({
          'nickname': newProfile.name,
          'faculty': AcademicHelper.resolveFaculty(newProfile.faculty),
          'study_program': AcademicHelper.resolveProdi(newProfile.studyProgram),
          'batch_year': newProfile.batchYear,
          'gender': newProfile.gender,
          'hobbies': hobbiesList,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      } catch (_) {}
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});
