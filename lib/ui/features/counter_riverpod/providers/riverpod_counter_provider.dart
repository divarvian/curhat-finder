import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiverpodCounter extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 0) {
      state--;
    }
  }

  void reset() {
    state = 0;
  }
}

final riverpodCounterProvider = NotifierProvider<RiverpodCounter, int>(() {
  return RiverpodCounter();
});
