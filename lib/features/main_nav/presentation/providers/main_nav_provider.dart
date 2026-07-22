import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Default ke tab 0 (Beranda)
  }

  void setIndex(int index) {
    state = index;
  }
}

final mainNavProvider = NotifierProvider<MainNavNotifier, int>(() {
  return MainNavNotifier();
});
