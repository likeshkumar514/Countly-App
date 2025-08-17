import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterController extends Notifier<int> {
  @override
  int build() => 0;

  void inc() => state++;
  void dec() => state--;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<CounterController, int>(
  () => CounterController(),
);
