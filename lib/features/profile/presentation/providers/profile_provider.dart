import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/academic_helper.dart';
import '../../domain/user_profile_model.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final initialProfile = UserProfile.empty(isLoading: true);
    Future.microtask(() => reloadProfile());
    return initialProfile;
  }

  Future<void> reloadProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

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
          name: data['nickname'] ?? data['full_name'] ?? (SupabaseService.currentUser?.userMetadata?['full_name'] ?? 'Mahasiswa'),
          role: data['role'] == 'konselor' ? 'Konselor' : 'Mahasiswa',
          email: SupabaseService.currentUser?.email ?? state.email,
          faculty: resolvedFaculty,
          studyProgram: resolvedProdi,
          batchYear: data['batch_year'] ?? state.batchYear,
          gender: data['gender'] ?? state.gender,
          hobby: hobbies.isNotEmpty ? hobbies.join(', ') : state.hobby,
          avatarPath: state.avatarPath,
          avatarUrl: data['avatar_url'] as String?,
          localAvatarPath: null, // Reset path lokal saat load ulang dari Supabase
          isLoading: false,
        );

        // Auto-migrasi ke Supabase jika sebelumnya tersimpan kode numerik
        if (resolvedFaculty != rawFaculty || resolvedProdi != rawProdi) {
          SupabaseService.client.from('profiles').update({
            'faculty': resolvedFaculty,
            'study_program': resolvedProdi,
          }).eq('id', userId);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> uploadAvatar(XFile file) async {
    final userId = SupabaseService.currentUserId;
    final previousState = state;
    final oldAvatarUrl = state.avatarUrl;

    // 1. Optimistic Update: langsung pakai path file lokal di HP agar instan
    state = state.copyWith(
      localAvatarPath: file.path,
    );

    if (userId != null) {
      try {
        final storage = StorageService();
        final publicUrl = await storage.uploadAvatar(file: file, userId: userId);
        if (publicUrl != null) {
          // 2. Bersihkan cache in-memory jika ada avatar lama
          if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
            PaintingBinding.instance.imageCache.evict(NetworkImage(oldAvatarUrl));
          }

          // 3. Simpan avatarUrl baru untuk sinkronisasi server, namun tetap pertahankan
          // localAvatarPath agar sesi aktif ini tidak men-download ulang via internet (ZERO-FLICKER)
          state = state.copyWith(
            avatarUrl: publicUrl,
            localAvatarPath: file.path,
          );
          return true;
        } else {
          state = previousState;
          return false;
        }
      } catch (e) {
        debugPrint('ProfileNotifier.uploadAvatar error: $e');
        state = previousState;
        return false;
      }
    }
    return true;
  }

  Future<bool> updateProfile(UserProfile newProfile) async {
    final previousProfile = state;
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
        return true;
      } catch (_) {
        state = previousProfile;
        return false;
      }
    }
    return true;
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});
