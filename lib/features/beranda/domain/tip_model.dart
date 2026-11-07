class TipModel {
  final String id;
  final String? userId;
  final String authorName;
  final String authorFaculty;
  final String authorGender;
  final String category;
  final String? title;
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
    this.title,
    required this.content,
    required this.likesCount,
    required this.bookmarksCount,
    required this.createdAt,
    this.isLikedByMe = false,
    this.isBookmarkedByMe = false,
  });

  /// Mengambil judul tips secara cerdas untuk ditampilkan di feed dan detail
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    final trimmed = content.trim();
    final newlineIdx = trimmed.indexOf('\n');
    if (newlineIdx > 0 && newlineIdx <= 70) {
      return trimmed.substring(0, newlineIdx).trim();
    }
    if (trimmed.length > 50) {
      return '${trimmed.substring(0, 48)}...';
    }
    return trimmed.isNotEmpty ? trimmed : 'Tips $category';
  }

  /// Mengambil isi deskripsi/tubuh tips
  String get displayDescription {
    if (title != null && title!.trim().isNotEmpty) {
      return content.trim();
    }
    final trimmed = content.trim();
    final newlineIdx = trimmed.indexOf('\n');
    if (newlineIdx > 0 && newlineIdx <= 70) {
      final sub = trimmed.substring(newlineIdx).trim();
      if (sub.isNotEmpty) return sub;
    }
    return trimmed;
  }

  factory TipModel.fromJson(Map<String, dynamic> json, {bool isLiked = false, bool isBookmarked = false}) {
    return TipModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      authorName: json['author_name'] as String? ?? 'Anon',
      authorFaculty: json['author_faculty'] as String? ?? 'FILKOM',
      authorGender: json['author_gender'] as String? ?? 'Laki-laki',
      category: json['category'] as String? ?? 'Self-care',
      title: json['title'] as String?,
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
    String? title,
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
      title: title ?? this.title,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isBookmarkedByMe: isBookmarkedByMe ?? this.isBookmarkedByMe,
    );
  }
}
