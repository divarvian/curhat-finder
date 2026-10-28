import 'counseling_models.dart';

class AnonSessionModel {
  final String id;
  final String? user1Id;
  final String? user2Id;
  final String mode;
  final String status;
  final bool isBotSession;
  final DateTime createdAt;
  final DateTime? endedAt;

  const AnonSessionModel({
    required this.id,
    this.user1Id,
    this.user2Id,
    required this.mode,
    required this.status,
    this.isBotSession = false,
    required this.createdAt,
    this.endedAt,
  });

  bool get isEnded => status == 'ended' || status == 'cancelled';
  bool get isActive => status == 'active';
  bool get isWaiting => status == 'waiting';

  factory AnonSessionModel.fromJson(Map<String, dynamic> json) {
    return AnonSessionModel(
      id: json['id'] as String? ?? '',
      user1Id: json['user1_id'] as String?,
      user2Id: json['user2_id'] as String?,
      mode: json['mode'] as String? ?? 'Cuma mau didengar',
      status: json['status'] as String? ?? 'active',
      isBotSession: json['is_bot_session'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())?.toLocal()
          : null,
    );
  }

  AnonSessionModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? mode,
    String? status,
    bool? isBotSession,
    DateTime? createdAt,
    DateTime? endedAt,
  }) {
    return AnonSessionModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      isBotSession: isBotSession ?? this.isBotSession,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

class AnonMatchResult {
  final String sessionId;
  final String status; // 'waiting' or 'active'
  final bool matched;
  final String role; // 'creator' or 'joiner'

  const AnonMatchResult({
    required this.sessionId,
    required this.status,
    required this.matched,
    required this.role,
  });

  factory AnonMatchResult.fromJson(Map<String, dynamic> json) {
    return AnonMatchResult(
      sessionId: json['session_id'] as String? ?? '',
      status: json['status'] as String? ?? 'waiting',
      matched: json['matched'] as bool? ?? false,
      role: json['role'] as String? ?? 'creator',
    );
  }
}

class AnonMessageModel {
  final String id;
  final String sessionId;
  final String? senderId;
  final String senderAlias;
  final String messageText;
  final bool isSystem;
  final DateTime createdAt;
  final MessageDeliveryStatus deliveryStatus;
  final bool isRead;
  final bool isDeletedForEveryone;
  final DateTime? deletedAt;
  final List<String> deletedForUsers;

  const AnonMessageModel({
    required this.id,
    required this.sessionId,
    this.senderId,
    required this.senderAlias,
    required this.messageText,
    this.isSystem = false,
    required this.createdAt,
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.isRead = false,
    this.isDeletedForEveryone = false,
    this.deletedAt,
    this.deletedForUsers = const [],
  });

  factory AnonMessageModel.fromJson(Map<String, dynamic> json) {
    final isDeleted = json['is_deleted_for_everyone'] as bool? ?? false;
    final isRead = json['is_read'] as bool? ?? false;
    final deletedUsersRaw = json['deleted_for_users'] as List<dynamic>?;
    final deletedUsers = deletedUsersRaw?.map((e) => e.toString()).toList() ?? const [];

    return AnonMessageModel(
      id: json['id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      senderId: json['sender_id'] as String?,
      senderAlias: json['sender_alias'] as String? ?? 'Anonim',
      messageText: json['message_text'] as String? ?? '',
      isSystem: json['is_system'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      deliveryStatus: isRead ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent,
      isRead: isRead,
      isDeletedForEveryone: isDeleted,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())?.toLocal()
          : null,
      deletedForUsers: deletedUsers,
    );
  }

  AnonMessageModel copyWith({
    String? id,
    String? sessionId,
    String? senderId,
    String? senderAlias,
    String? messageText,
    bool? isSystem,
    DateTime? createdAt,
    MessageDeliveryStatus? deliveryStatus,
    bool? isRead,
    bool? isDeletedForEveryone,
    DateTime? deletedAt,
    List<String>? deletedForUsers,
  }) {
    return AnonMessageModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      senderId: senderId ?? this.senderId,
      senderAlias: senderAlias ?? this.senderAlias,
      messageText: messageText ?? this.messageText,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      isRead: isRead ?? this.isRead,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedForUsers: deletedForUsers ?? this.deletedForUsers,
    );
  }
}

class AnonReportModel {
  final String id;
  final String sessionId;
  final String reporterId;
  final String? reportedUserId;
  final String reason;
  final String? details;
  final String status;
  final DateTime createdAt;

  const AnonReportModel({
    required this.id,
    required this.sessionId,
    required this.reporterId,
    this.reportedUserId,
    required this.reason,
    this.details,
    required this.status,
    required this.createdAt,
  });

  factory AnonReportModel.fromJson(Map<String, dynamic> json) {
    return AnonReportModel(
      id: json['id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      reporterId: json['reporter_id'] as String? ?? '',
      reportedUserId: json['reported_user_id'] as String?,
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
