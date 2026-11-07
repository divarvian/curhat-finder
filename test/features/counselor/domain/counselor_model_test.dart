import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';

void main() {
  group('CounselorModel Domain Tests', () {
    test('CounselorArticle and CounselorForumThread correctly parse JSON', () {
      final articleJson = {
        'id': 'art-1',
        'author_id': 'user-1',
        'title': 'Cara Mengatasi Burnout',
        'category': 'Self-care',
        'content': 'Tips relaksasi dan meditasi',
        'likes_count': 5,
        'created_at': DateTime.now().toIso8601String(),
      };
      final article = CounselorArticle.fromJson(articleJson);
      expect(article.id, 'art-1');
      expect(article.title, 'Cara Mengatasi Burnout');
      expect(article.category, 'Self-care');
      expect(article.likesCount, 5);

      final threadJson = {
        'id': 'thread-1',
        'author_id': 'counselor-1',
        'title': 'Studi Kasus Mahasiswa Cemas',
        'topic': 'Studi Kasus',
        'content': 'Diskusi penanganan mahasiswa tingkat akhir',
        'replies_count': 3,
        'created_at': DateTime.now().toIso8601String(),
        'profiles': {
          'nickname': 'Arya',
          'faculty': 'FILKOM',
        },
      };
      final thread = CounselorForumThread.fromJson(threadJson);
      expect(thread.id, 'thread-1');
      expect(thread.authorName, 'Arya');
      expect(thread.authorFaculty, 'FILKOM');
      expect(thread.topic, 'Studi Kasus');
      expect(thread.repliesCount, 3);
    });
  });
}
