class CounselorProfile {
  final String name;
  final String email;
  final String faculty;
  final String studyProgram;
  final String batchYear;
  final String gender;
  final String role;
  final String avatarPath;
  final List<String> topics;
  final bool isOnline;
  final int activeSessions;
  final int totalHelped;
  final String responseTime;

  const CounselorProfile({
    required this.name,
    required this.email,
    required this.faculty,
    required this.studyProgram,
    required this.batchYear,
    required this.gender,
    required this.role,
    required this.avatarPath,
    required this.topics,
    required this.isOnline,
    required this.activeSessions,
    required this.totalHelped,
    required this.responseTime,
  });

  CounselorProfile copyWith({
    String? name,
    String? email,
    String? faculty,
    String? studyProgram,
    String? batchYear,
    String? gender,
    String? role,
    String? avatarPath,
    List<String>? topics,
    bool? isOnline,
    int? activeSessions,
    int? totalHelped,
    String? responseTime,
  }) {
    return CounselorProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      studyProgram: studyProgram ?? this.studyProgram,
      batchYear: batchYear ?? this.batchYear,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      avatarPath: avatarPath ?? this.avatarPath,
      topics: topics ?? this.topics,
      isOnline: isOnline ?? this.isOnline,
      activeSessions: activeSessions ?? this.activeSessions,
      totalHelped: totalHelped ?? this.totalHelped,
      responseTime: responseTime ?? this.responseTime,
    );
  }
}

class CounselorChatSession {
  final String id;
  final String studentName;
  final String studentGender;
  final String studentFaculty;
  final String statusDescription;
  final bool isOnline;
  final String lastMessage;
  final String lastMessageTime;

  const CounselorChatSession({
    required this.id,
    required this.studentName,
    required this.studentGender,
    required this.studentFaculty,
    required this.statusDescription,
    this.isOnline = true,
    this.lastMessage = '',
    this.lastMessageTime = '',
  });
}

class CounselorChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String timestamp;
  final bool isTyping;

  const CounselorChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.isTyping = false,
  });
}
