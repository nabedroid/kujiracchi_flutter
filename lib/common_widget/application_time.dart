

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

class ApplicationTimeNotifier extends StateNotifier {
  ApplicationTimeNotifier(super.state);
}

final applicationTimeProvider = StateProvider.autoDispose<DateTime>((ref) {
  
  final config = ref.watch(configProvider);
  
  return DateTime.now().add(Duration(milliseconds: config.systemTimeDiff));
});