class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'admin@example.com' && password == 'password123') {
      return {
        'username': 'Administrator',
        'email': email,
      };
    }
    throw Exception('Email atau password salah. Coba lagi.');
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'username': username,
      'email': email,
    };
  }
}
