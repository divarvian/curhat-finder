import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/main_nav/presentation/providers/main_nav_provider.dart';

void main() {
  group('MainNavNotifier Tests', () {
    test('MainNavNotifier switches index and resets to 0 properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(mainNavProvider), 0);
      container.read(mainNavProvider.notifier).setIndex(3);
      expect(container.read(mainNavProvider), 3);
      container.read(mainNavProvider.notifier).setIndex(0);
      expect(container.read(mainNavProvider), 0);
    });
  });
}
