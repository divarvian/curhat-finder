import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class AuthService {
  final SupabaseClient? _client;

  AuthService([SupabaseClient? client])
      : _client = client ?? SupabaseService.maybeClient;

  Future<bool> checkUserExists(String email) async {
    try {
      final client = _client ?? SupabaseService.client;
      final res = await client.rpc('check_user_exists', params: {
        'lookup_email': email.trim().toLowerCase(),
      });
      return res == true;
    } catch (_) {
      return false;
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final client = _client ?? SupabaseService.client;
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
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
    final client = _client ?? SupabaseService.client;
    return await client.auth.signUp(
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
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final client = _client ?? SupabaseService.client;
      final response = await client
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
    final client = _client ?? SupabaseService.client;
    await client.auth.signOut();
  }

  User? get currentUser => _client?.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
}
