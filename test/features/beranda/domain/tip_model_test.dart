import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/beranda/domain/tip_model.dart';

void main() {
  group('TipModel Tests', () {
    test('TipModel displayTitle and displayDescription handle explicit title and fallback gracefully', () {
      final tipWithTitle = TipModel(
        id: 'tip-1',
        authorName: 'Kak Harry',
        authorFaculty: 'FEB',
        authorGender: 'Laki-laki',
        category: 'Productivity',
        title: 'Tips mencapai produktifitas tinggi dalam diam',
        content: 'Work hard in silence. Let success be your noise.',
        likesCount: 99,
        bookmarksCount: 20,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(tipWithTitle.displayTitle, 'Tips mencapai produktifitas tinggi dalam diam');
      expect(tipWithTitle.displayDescription, 'Work hard in silence. Let success be your noise.');

      final tipFallback = TipModel(
        id: 'tip-2',
        authorName: 'Anon',
        authorFaculty: 'FILKOM',
        authorGender: 'Laki-laki',
        category: 'Afirmasi',
        content: 'Tips bernafas tenang\nTarik nafas 4 detik dan hembuskan perlahan.',
        likesCount: 10,
        bookmarksCount: 2,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(tipFallback.displayTitle, 'Tips bernafas tenang');
      expect(tipFallback.displayDescription, 'Tarik nafas 4 detik dan hembuskan perlahan.');
    });
  });
}
