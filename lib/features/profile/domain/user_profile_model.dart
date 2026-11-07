class UserProfile {
  final String name;
  final String role;
  final String email;
  final String faculty;
  final String studyProgram;
  final String batchYear;
  final String gender;
  final String hobby;
  final String avatarPath;
  final String? avatarUrl; // Remote public URL from Supabase storage
  final String? localAvatarPath; // For picked image from device during active session
  final bool isLoading;

  UserProfile({
    required this.name,
    required this.role,
    required this.email,
    required this.faculty,
    required this.studyProgram,
    required this.batchYear,
    required this.gender,
    required this.hobby,
    required this.avatarPath,
    this.avatarUrl,
    this.localAvatarPath,
    this.isLoading = false,
  });

  UserProfile copyWith({
    String? name,
    String? role,
    String? email,
    String? faculty,
    String? studyProgram,
    String? batchYear,
    String? gender,
    String? hobby,
    String? avatarPath,
    String? avatarUrl,
    String? localAvatarPath,
    bool? isLoading,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      studyProgram: studyProgram ?? this.studyProgram,
      batchYear: batchYear ?? this.batchYear,
      gender: gender ?? this.gender,
      hobby: hobby ?? this.hobby,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static UserProfile empty({bool isLoading = true}) => UserProfile(
        name: '',
        role: 'Mahasiswa',
        email: '',
        faculty: '',
        studyProgram: '',
        batchYear: '',
        gender: '',
        hobby: '',
        avatarPath: 'assets/images/mascot.png',
        avatarUrl: null,
        localAvatarPath: null,
        isLoading: isLoading,
      );
}
