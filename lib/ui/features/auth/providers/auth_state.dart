class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? username;
  final String? email;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.username,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? username,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }
}
