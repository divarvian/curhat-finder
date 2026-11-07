import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/beranda/presentation/providers/tips_interaction_provider.dart';

void main() {
  group('TipsInteractionState Tests', () {
    test('TipsInteractionState handles optimistic likesCount deltas properly', () {
      const state = TipsInteractionState(
        likedTipIds: {'tip-1'},
        bookmarkedTipIds: {'tip-2'},
        likesCountDeltas: {'tip-1': 1, 'tip-2': -1},
      );

      expect(state.likedTipIds.contains('tip-1'), true);
      expect(state.likedTipIds.contains('tip-2'), false);
      expect(state.bookmarkedTipIds.contains('tip-2'), true);

      final copy = state.copyWith(likesCountDeltas: {'tip-1': 1, 'tip-min': -5});
      final total1 = (copy.likesCountDeltas['tip-1'] ?? 0) + 10;
      expect(total1, 11);
      final clamped = (0 + (copy.likesCountDeltas['tip-min'] ?? 0)).clamp(0, 99999);
      expect(clamped, 0);
    });
  });
}
