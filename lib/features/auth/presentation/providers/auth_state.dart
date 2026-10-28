class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? userId;
  final String? username;
  final String? email;
  final String? role; // 'mahasiswa' atau 'konselor'
  final bool isVerified;
  final String counselorStatus; // 'unregistered', 'pending', 'approved', 'rejected'
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.userId,
    this.username,
    this.email,
    this.role,
    this.isVerified = true,
    this.counselorStatus = 'approved',
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? userId,
    String? username,
    String? email,
    String? role,
    bool? isVerified,
    String? counselorStatus,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      counselorStatus: counselorStatus ?? this.counselorStatus,
      errorMessage: errorMessage,
    );
  }
}
