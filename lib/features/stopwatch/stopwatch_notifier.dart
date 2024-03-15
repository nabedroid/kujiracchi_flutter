import 'dart:async';

import 'package:flutter/material.dart';

enum StopwatchStatus {
  init,
  counting,
  stop,
}

class Stopwatch {

  StopwatchStatus status = StopwatchStatus.init;
  int startTime = 0;
  int countTime = 0;

  Stopwatch({
    required this.startTime,
    required this.countTime,
    required this.status,
  });
}

class StopwatchNotifier extends ChangeNotifier {

  final Stopwatch _sw = Stopwatch(startTime: 0, countTime: 0, status: StopwatchStatus.init);
  int get count => _sw.status == StopwatchStatus.counting ? DateTime.now().millisecondsSinceEpoch - _sw.startTime : _sw.countTime;
  StopwatchStatus get status => _sw.status;
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void start() {
    switch (_sw.status) {
      case StopwatchStatus.init:
      // 新規
        _sw.startTime = DateTime.now().millisecondsSinceEpoch;
        _sw.countTime = 0;
        _sw.status = StopwatchStatus.counting;
        if (_timer?.isActive ?? false) {
          _timer?.cancel();
        }
        _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
          notifyListeners();
        });
        notifyListeners();
      case StopwatchStatus.counting:
        break;
      case StopwatchStatus.stop:
      // 再開
        _sw.startTime = DateTime.now().millisecondsSinceEpoch - _sw.countTime;
        _sw.countTime = 0;
        _sw.status = StopwatchStatus.counting;
        // 不要だけど考慮漏れのため一応キャンセルしておく
        if (_timer?.isActive ?? false) {
          _timer?.cancel();
        }
        _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
          notifyListeners();
        });
      default:
        throw Exception('想定外のStopwatchStatusが指定されています');
    }
  }

  void stop() {
    if (_sw.status == StopwatchStatus.counting) {
      _sw.countTime = DateTime.now().millisecondsSinceEpoch - _sw.startTime;
      _sw.startTime = 0;
      _sw.status = StopwatchStatus.stop;
      if (_timer?.isActive ?? false) {
        _timer?.cancel();
      }
      notifyListeners();
    }
  }

  void reset() {
    if (_sw.status == StopwatchStatus.stop) {
      _sw.startTime = 0;
      _sw.countTime = 0;
      _sw.status = StopwatchStatus.init;
      // 不要だけど考慮漏れのため一応キャンセルしておく
      if (_timer?.isActive ?? false) {
        _timer?.cancel();
      }
      notifyListeners();
    }
  }
}

