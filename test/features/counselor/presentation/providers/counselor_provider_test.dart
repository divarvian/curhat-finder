import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';

void main() {
  group('CounselorProvider Tests', () {
    test('CounselorState starts clean without hardcoded Carmen or demo sessions', () {
      const state = CounselorState();
      expect(state.isLoading, isTrue);
      expect(state.profile.name, 'Konselor');
      expect(state.profile.name, isNot(contains('Carmen')));
      expect(state.profile.email, isEmpty);
      expect(state.sessions, isEmpty);
      expect(state.messages, isEmpty);
      expect(state.queues, isEmpty);
      expect(state.activeSessions, isEmpty);
    });

    test('CounselorNotifier setNavIndex updates state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counselorProvider).currentNavIndex, 0);
      container.read(counselorProvider.notifier).setNavIndex(2);
      expect(container.read(counselorProvider).currentNavIndex, 2);
      container.read(counselorProvider.notifier).setNavIndex(0);
      expect(container.read(counselorProvider).currentNavIndex, 0);
    });
  });
}
