import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stopwatch_notifier.dart';

final stopwatchProvider = ChangeNotifierProvider.autoDispose<StopwatchNotifier>((ref) {
  return StopwatchNotifier();
});
