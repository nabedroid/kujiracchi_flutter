import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

class TimerNotifier extends StateNotifier<int> {
  final int duration;
  int _startTime = 0;
  int _stopTime = 0;
  Timer? _timer;

  TimerNotifier(this.duration, [autoStart = true]) : super(0) {
    if (autoStart) {
      start();
    }
  }

  void _running(Timer timer) {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = now - _startTime;
  }

  void start() {
    // 稼働中の場合は何もしない
    if (_timer?.isActive ?? false) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_stopTime == 0) {
      // 新規開始
      _startTime = now;
    } else {
      // 再開
      _startTime = now - state;
      _stopTime = 0;
    }
    _timer = Timer.periodic(Duration(milliseconds: duration), _running);
  }

  void stop() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      final now = DateTime.now().millisecondsSinceEpoch;
      state = now - _startTime;
      _startTime = 0;
      _stopTime = now;
    }
  }

  void reset() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _stopTime = 0;
    state = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// final timerProvider = StateNotifierProvider.autoDispose.family<TimerNotifier, int, int>((ref, duration) {
//   return TimerNotifier(duration);
// });
final timerProvider =
StateNotifierProvider.autoDispose<TimerNotifier, int>((ref) {
  return TimerNotifier(50);
});

final systemTimerProvider = StateProvider.autoDispose<DateTime>((ref) {
  final _ = ref.watch(timerProvider);

  return DateTime.now();
});

final applicationTimerProvider = StateProvider.autoDispose<DateTime>((ref) {
  final _ = ref.watch(timerProvider);
  final config = ref.watch(configProvider);

  return DateTime.now().add(Duration(milliseconds: config.systemTimeDiff));
});
