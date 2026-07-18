import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required this._authRepository}) 
      : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.login(email, password);
      emit(AuthSuccess(username: user.username, email: user.email));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.register(username, email, password);
      emit(AuthSuccess(username: user.username, email: user.email));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void logout() {
    emit(AuthInitial());
  }
}
