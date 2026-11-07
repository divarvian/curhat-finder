class RoomModel {
  final String id;
  final String? userId;
  final String authorName;
  final String authorFaculty;
  final String authorGender;
  final String category;
  final String title;
  final String content;
  final int likesCount;
  final int commentsCount;
  final int bookmarksCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isBookmarked;

  const RoomModel({
    required this.id,
    this.userId,
    this.authorName = 'Anonim',
    this.authorFaculty = 'FILKOM',
    this.authorGender = 'Laki-laki',
    required this.category,
    required this.title,
    required this.content,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.bookmarksCount = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  /// Getter untuk kompatibilitas tampilan UI
  String get authorTag => '$authorName • $authorFaculty';

  factory RoomModel.fromJson(Map<String, dynamic> json, {bool isLiked = false, bool isBookmarked = false}) {
    final rawTag = json['author_tag'] as String?;
    final parsedName = json['author_name'] as String? ??
        (rawTag != null ? (rawTag.contains(' • ') ? rawTag.split(' • ').first : rawTag) : 'Anonim');
    final parsedFaculty = json['author_faculty'] as String? ??
        (rawTag != null && rawTag.contains(' • ') ? rawTag.split(' • ').last : 'FILKOM');
    final parsedGender = json['author_gender'] as String? ?? 'Laki-laki';

    return RoomModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      authorName: parsedName,
      authorFaculty: parsedFaculty,
      authorGender: parsedGender,
      category: json['category'] as String? ?? 'Umum',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isLiked: isLiked,
      isBookmarked: isBookmarked,
    );
  }

  RoomModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorFaculty,
    String? authorGender,
    String? category,
    String? title,
    String? content,
    int? likesCount,
    int? commentsCount,
    int? bookmarksCount,
    DateTime? createdAt,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return RoomModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorFaculty: authorFaculty ?? this.authorFaculty,
      authorGender: authorGender ?? this.authorGender,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class RoomCommentModel {
  final String id;
  final String roomId;
  final String? userId;
  final String authorName;
  final String authorFaculty;
  final String authorRole;
  final String content;
  final int likesCount;
  final DateTime createdAt;

  const RoomCommentModel({
    required this.id,
    required this.roomId,
    this.userId,
    this.authorName = 'Teman Kampus',
    this.authorFaculty = 'FILKOM',
    this.authorRole = 'mahasiswa',
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
  });

  /// Apakah penulis komentar adalah konselor sebaya terverifikasi
  bool get isCounselor => authorRole.toLowerCase() == 'konselor';

  /// Format badge tag untuk tampilan UI
  String get authorTag => isCounselor ? '$authorName (Konselor Sebaya)' : '$authorName • $authorFaculty';

  factory RoomCommentModel.fromJson(Map<String, dynamic> json) {
    final rawTag = json['author_tag'] as String?;
    final parsedName = json['author_name'] as String? ??
        (rawTag != null ? (rawTag.contains(' • ') ? rawTag.split(' • ').first : rawTag) : 'Teman Kampus');
    final parsedFaculty = json['author_faculty'] as String? ??
        (rawTag != null && rawTag.contains(' • ') ? rawTag.split(' • ').last : 'FILKOM');
    final parsedRole = json['author_role'] as String? ??
        (rawTag != null && rawTag.toLowerCase().contains('konselor') ? 'konselor' : 'mahasiswa');

    return RoomCommentModel(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      authorName: parsedName,
      authorFaculty: parsedFaculty,
      authorRole: parsedRole,
      content: json['content'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
