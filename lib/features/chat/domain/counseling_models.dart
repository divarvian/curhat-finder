class CounselingQueueModel {
  final String id;
  final String studentId;
  final String studentAlias;
  final String studentGender;
  final String studentFaculty;
  final String? preferredTopic;
  final String status;
  final String? assignedCounselorId;
  final String? sessionId;
  final DateTime createdAt;

  const CounselingQueueModel({
    required this.id,
    required this.studentId,
    required this.studentAlias,
    required this.studentGender,
    required this.studentFaculty,
    this.preferredTopic,
    required this.status,
    this.assignedCounselorId,
    this.sessionId,
    required this.createdAt,
  });

  factory CounselingQueueModel.fromJson(Map<String, dynamic> json) {
    return CounselingQueueModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      studentAlias: json['student_alias'] as String? ?? 'Anonym',
      studentGender: json['student_gender'] as String? ?? 'Perempuan',
      studentFaculty: json['student_faculty'] as String? ?? 'FILKOM',
      preferredTopic: json['preferred_topic'] as String?,
      status: json['status'] as String? ?? 'waiting',
      assignedCounselorId: json['assigned_counselor_id'] as String?,
      sessionId: json['session_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_alias': studentAlias,
      'student_gender': studentGender,
      'student_faculty': studentFaculty,
      'preferred_topic': preferredTopic,
      'status': status,
      'assigned_counselor_id': assignedCounselorId,
      'session_id': sessionId,
    };
  }
}

class CounselingSessionModel {
  final String id;
  final String? queueId;
  final String studentId;
  final String counselorId;
  final String studentAlias;
  final String studentFaculty;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? rating;
  final String? reviewNote;
  final List<String>? reviewTags;

  const CounselingSessionModel({
    required this.id,
    this.queueId,
    required this.studentId,
    required this.counselorId,
    required this.studentAlias,
    required this.studentFaculty,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.rating,
    this.reviewNote,
    this.reviewTags,
  });

  factory CounselingSessionModel.fromJson(Map<String, dynamic> json) {
    return CounselingSessionModel(
      id: json['id'] as String,
      queueId: json['queue_id'] as String?,
      studentId: json['student_id'] as String,
      counselorId: json['counselor_id'] as String,
      studentAlias: json['student_alias'] as String? ?? 'Anonym',
      studentFaculty: json['student_faculty'] as String? ?? 'FILKOM',
      status: json['status'] as String? ?? 'active',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String).toLocal()
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String).toLocal()
          : null,
      rating: json['rating'] as int?,
      reviewNote: json['review_note'] as String?,
      reviewTags: (json['review_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_id': queueId,
      'student_id': studentId,
      'counselor_id': counselorId,
      'student_alias': studentAlias,
      'student_faculty': studentFaculty,
      'status': status,
      'rating': rating,
      'review_note': reviewNote,
      'review_tags': reviewTags,
    };
  }
}

enum MessageDeliveryStatus {
  sending, // Optimistic UI: sedang dikirim / loading clock icon
  sent,    // Terkirim ke Supabase: centang abu-abu
  read,    // Dibaca lawan bicara: centang biru/cyan
  failed,  // Gagal terkirim: tanda seru merah
}

class ChatMessageModel {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderRole; // 'student' or 'counselor' or 'system'
  final String messageText;
  final bool isRead;
  final DateTime createdAt;
  final MessageDeliveryStatus deliveryStatus;
  final bool isDeletedForEveryone;
  final DateTime? deletedAt;
  final List<String> deletedForUsers;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderRole,
    required this.messageText,
    required this.isRead,
    required this.createdAt,
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.isDeletedForEveryone = false,
    this.deletedAt,
    this.deletedForUsers = const [],
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final isRead = json['is_read'] as bool? ?? false;
    final isDeleted = json['is_deleted_for_everyone'] as bool? ?? false;
    final deletedUsersRaw = json['deleted_for_users'] as List<dynamic>?;
    final deletedUsers = deletedUsersRaw?.map((e) => e.toString()).toList() ?? const [];

    return ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderId: json['sender_id'] as String,
      senderRole: json['sender_role'] as String? ?? 'student',
      messageText: json['message_text'] as String? ?? '',
      isRead: isRead,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      deliveryStatus: isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
      isDeletedForEveryone: isDeleted,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())?.toLocal()
          : null,
      deletedForUsers: deletedUsers,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? sessionId,
    String? senderId,
    String? senderRole,
    String? messageText,
    bool? isRead,
    DateTime? createdAt,
    MessageDeliveryStatus? deliveryStatus,
    bool? isDeletedForEveryone,
    DateTime? deletedAt,
    List<String>? deletedForUsers,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      messageText: messageText ?? this.messageText,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedForUsers: deletedForUsers ?? this.deletedForUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message_text': messageText,
      'is_read': isRead,
    };
  }
}
