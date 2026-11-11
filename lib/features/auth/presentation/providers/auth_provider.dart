import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:curhat_finder/features/auth/data/auth_service.dart';
import 'package:curhat_finder/features/auth/data/auth_repository.dart';
import 'package:curhat_finder/core/services/notification_service.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/core/utils/app_error_translator.dart';
import 'package:curhat_finder/core/utils/ub_email_validator.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/profile/presentation/providers/profile_provider.dart';
import 'auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthRepository(authService: service);
});

class AuthNotifier extends Notifier<AuthState> {
  static bool? lastKnownIsVerified;
  static String? lastKnownRole;

  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _checkInitialAuth();
    return const AuthState();
  }

  void _checkInitialAuth() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final profile = await _authRepository.getProfile(user.id);
      final role = profile?['role'] ?? 'mahasiswa';
      final isVerified = profile?['is_verified'] as bool? ?? (role != 'konselor');
      final counselorStatus = profile?['counselor_status'] as String? ?? (role == 'konselor' ? 'pending' : 'approved');

      lastKnownRole = role;
      lastKnownIsVerified = isVerified;

      if (role == 'konselor' && isVerified == true) {
        try {
          SupabaseService.client.auth.updateUser(
            UserAttributes(data: {'is_verified': true, 'role': 'konselor'}),
          );
        } catch (_) {}
      }

      state = state.copyWith(
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        username: profile?['nickname'] ?? profile?['full_name'] ?? user.email,
        role: role,
        isVerified: isVerified,
        counselorStatus: counselorStatus,
      );
      NotificationService.syncTokenToSupabase(user.id);
    }
  }

  Future<void> refreshProfile() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final profile = await _authRepository.getProfile(user.id);
      final role = profile?['role'] ?? 'mahasiswa';
      final isVerified = profile?['is_verified'] as bool? ?? (role != 'konselor');
      final counselorStatus = profile?['counselor_status'] as String? ?? (role == 'konselor' ? 'pending' : 'approved');

      lastKnownRole = role;
      lastKnownIsVerified = isVerified;

      if (role == 'konselor' && isVerified == true) {
        try {
          SupabaseService.client.auth.updateUser(
            UserAttributes(data: {'is_verified': true, 'role': 'konselor'}),
          );
        } catch (_) {}
      }

      state = state.copyWith(
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        username: profile?['nickname'] ?? profile?['full_name'] ?? user.email,
        role: role,
        isVerified: isVerified,
        counselorStatus: counselorStatus,
      );
    }
  }

  Future<bool> checkUserExists(String email) {
    if (!UbEmailValidator.isUbEmail(email)) {
      return Future.value(false);
    }
    return _authRepository.checkUserExists(email);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!UbEmailValidator.isUbEmail(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: UbEmailValidator.invalidDomainMessage,
      );
      return false;
    }

    try {
      final response = await _authRepository.login(email, password);
      final user = response.user;
      if (user == null) throw Exception('Gagal mendapatkan data pengguna.');

      final profile = await _authRepository.getProfile(user.id);
      final role = profile?['role'] ?? 'mahasiswa';
      final isVerified = profile?['is_verified'] as bool? ?? (role != 'konselor');
      final counselorStatus = profile?['counselor_status'] as String? ?? (role == 'konselor' ? 'pending' : 'approved');

      lastKnownRole = role;
      lastKnownIsVerified = isVerified;

      if (role == 'konselor' && isVerified == true) {
        try {
          SupabaseService.client.auth.updateUser(
            UserAttributes(data: {'is_verified': true, 'role': 'konselor'}),
          );
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        username: profile?['nickname'] ?? profile?['full_name'] ?? user.email,
        role: role,
        isVerified: isVerified,
        counselorStatus: counselorStatus,
      );

      NotificationService.syncTokenToSupabase(user.id);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppErrorTranslator.translateAuthError(e),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String? nickname,
    String? gender,
    String? batchYear,
    String? faculty,
    String? studyProgram,
    List<String>? hobbies,
    List<String>? topics,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!UbEmailValidator.isUbEmail(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: UbEmailValidator.invalidDomainMessage,
      );
      return false;
    }

    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        nickname: nickname,
        gender: gender,
        batchYear: batchYear,
        faculty: faculty,
        studyProgram: studyProgram,
        hobbies: hobbies,
        topics: topics,
      );

      final user = response.user;
      final isVerified = role != 'konselor';

      lastKnownRole = role;
      lastKnownIsVerified = isVerified;

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: user != null,
        userId: user?.id,
        email: user?.email ?? email,
        username: nickname ?? fullName,
        role: role,
        isVerified: isVerified,
        counselorStatus: role == 'konselor' ? 'pending' : 'approved',
      );

      if (user != null) {
        NotificationService.syncTokenToSupabase(user.id);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppErrorTranslator.translateAuthError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    lastKnownRole = null;
    lastKnownIsVerified = null;
    await NotificationService.clearToken();
    await _authRepository.logout();
    state = const AuthState();
    ref.read(counselorProvider.notifier).reset();
    ref.read(profileProvider.notifier).reloadProfile();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
