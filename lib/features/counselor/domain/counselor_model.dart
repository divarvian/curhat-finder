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

  static const empty = CounselorProfile(
    name: 'Konselor',
    email: '',
    faculty: '',
    studyProgram: '',
    batchYear: '',
    gender: '',
    role: 'Konselor',
    avatarPath: 'assets/images/mascot.png',
    topics: [],
    isOnline: false,
    activeSessions: 0,
    totalHelped: 0,
    responseTime: '-',
  );

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
  final bool isDeletedForEveryone;
  final List<String> deletedForUsers;
  final bool isRead;
  final DateTime? createdAt;

  const CounselorChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.isTyping = false,
    this.isDeletedForEveryone = false,
    this.deletedForUsers = const [],
    this.isRead = false,
    this.createdAt,
  });

  CounselorChatMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    String? timestamp,
    bool? isTyping,
    bool? isDeletedForEveryone,
    List<String>? deletedForUsers,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return CounselorChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedForUsers: deletedForUsers ?? this.deletedForUsers,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
