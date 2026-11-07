import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/jurnal/presentation/providers/jurnal_provider.dart';

void main() {
  group('JurnalProvider & JurnalState Tests', () {
    test('JurnalState handles isSaving mutex flag and clearMood correctly', () {
      final state = JurnalState(
        selectedMood: 2,
        isSaving: false,
      );
      expect(state.isSaving, isFalse);
      expect(state.selectedMood, 2);

      final savingState = state.copyWith(isSaving: true);
      expect(savingState.isSaving, isTrue);
      expect(savingState.selectedMood, 2);

      final clearedMoodState = savingState.copyWith(isSaving: false, clearMood: true);
      expect(clearedMoodState.isSaving, isFalse);
      expect(clearedMoodState.selectedMood, isNull);
    });
  });
}
