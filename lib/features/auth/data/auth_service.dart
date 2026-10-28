import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  Future<bool> checkUserExists(String email) async {
    try {
      final res = await _client.rpc('check_user_exists', params: {
        'lookup_email': email.trim().toLowerCase(),
      });
      return res == true;
    } catch (_) {
      return false;
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception(e.toString().replaceAll('AuthException(message: ', '').replaceAll(')', ''));
    }
  }

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
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'role': role,
          'full_name': fullName,
          'nickname': nickname,
          'gender': gender,
          'batch_year': batchYear,
          'faculty': faculty,
          'study_program': studyProgram,
          'hobbies': hobbies ?? [],
          'topics': topics ?? [],
        },
      );
      return response;
    } catch (e) {
      throw Exception(e.toString().replaceAll('AuthException(message: ', '').replaceAll(')', ''));
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
}
