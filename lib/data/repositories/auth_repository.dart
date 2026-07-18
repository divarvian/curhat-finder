import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({required this._authService});

  Future<User> login(String email, String password) async {
    final rawData = await _authService.login(email, password);
    return User(
      username: rawData['username'] as String,
      email: rawData['email'] as String,
    );
  }

  Future<User> register(String username, String email, String password) async {
    final rawData = await _authService.register(username, email, password);
    return User(
      username: rawData['username'] as String,
      email: rawData['email'] as String,
    );
  }
}
