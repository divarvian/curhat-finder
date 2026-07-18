import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthNotifier({required this._authRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _username;
  String? get username => _username;

  String? _email;
  String? get email => _email;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(email, password);
      _isLoggedIn = true;
      _username = user.username;
      _email = user.email;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.register(username, email, password);
      _isLoggedIn = true;
      _username = user.username;
      _email = user.email;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _username = null;
    _email = null;
    _errorMessage = null;
    notifyListeners();
  }
}
