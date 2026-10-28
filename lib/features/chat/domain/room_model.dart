class RoomModel {
  final String id;
  final String? userId;
  final String authorTag;
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
    required this.authorTag,
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

  factory RoomModel.fromJson(Map<String, dynamic> json, {bool isLiked = false, bool isBookmarked = false}) {
    return RoomModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      authorTag: json['author_tag'] as String? ?? 'Anonim • UB',
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
    String? authorTag,
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
      authorTag: authorTag ?? this.authorTag,
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
  final String authorTag;
  final String content;
  final int likesCount;
  final DateTime createdAt;

  const RoomCommentModel({
    required this.id,
    required this.roomId,
    this.userId,
    required this.authorTag,
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
  });

  factory RoomCommentModel.fromJson(Map<String, dynamic> json) {
    return RoomCommentModel(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      authorTag: json['author_tag'] as String? ?? 'Teman Kampus',
      content: json['content'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
