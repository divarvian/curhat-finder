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
  final String? localAvatarPath; // For picked image from device

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
    this.localAvatarPath,
  });
}
