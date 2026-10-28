import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository({required this.authService});

  Future<bool> checkUserExists(String email) => authService.checkUserExists(email);

  Future<AuthResponse> login(String email, String password) =>
      authService.login(email, password);

  Future<AuthResponse> register({
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
  }) =>
      authService.register(
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

  Future<Map<String, dynamic>?> getProfile(String userId) =>
      authService.getProfile(userId);

  Future<void> logout() => authService.logout();

  User? get currentUser => authService.currentUser;
  bool get isLoggedIn => authService.isLoggedIn;
}
