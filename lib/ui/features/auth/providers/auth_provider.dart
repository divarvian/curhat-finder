import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthRepository(authService: service);
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        email: user.email,
        username: user.username,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.register(username, email, password);
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        username: user.username,
        email: user.email,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
