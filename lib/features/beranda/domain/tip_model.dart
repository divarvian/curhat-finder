class TipModel {
  final String id;
  final String? userId;
  final String authorName;
  final String authorFaculty;
  final String authorGender;
  final String category;
  final String content;
  final int likesCount;
  final int bookmarksCount;
  final DateTime createdAt;
  final bool isLikedByMe;
  final bool isBookmarkedByMe;

  const TipModel({
    required this.id,
    this.userId,
    required this.authorName,
    required this.authorFaculty,
    required this.authorGender,
    required this.category,
    required this.content,
    required this.likesCount,
    required this.bookmarksCount,
    required this.createdAt,
    this.isLikedByMe = false,
    this.isBookmarkedByMe = false,
  });

  factory TipModel.fromJson(Map<String, dynamic> json, {bool isLiked = false, bool isBookmarked = false}) {
    return TipModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      authorName: json['author_name'] as String? ?? 'Anon',
      authorFaculty: json['author_faculty'] as String? ?? 'FILKOM',
      authorGender: json['author_gender'] as String? ?? 'Laki-laki',
      category: json['category'] as String? ?? 'Self-care',
      content: json['content'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isLikedByMe: isLiked,
      isBookmarkedByMe: isBookmarked,
    );
  }

  TipModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorFaculty,
    String? authorGender,
    String? category,
    String? content,
    int? likesCount,
    int? bookmarksCount,
    DateTime? createdAt,
    bool? isLikedByMe,
    bool? isBookmarkedByMe,
  }) {
    return TipModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorFaculty: authorFaculty ?? this.authorFaculty,
      authorGender: authorGender ?? this.authorGender,
      category: category ?? this.category,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isBookmarkedByMe: isBookmarkedByMe ?? this.isBookmarkedByMe,
    );
  }
}
