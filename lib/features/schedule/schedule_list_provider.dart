import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/shared_preference.dart';

import 'package:kujiracchi_dart/features/schedule/schedule_list_notifier.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list.dart';

final scheduleListProvider = StateNotifierProvider.autoDispose<ScheduleListNotifier, ScheduleList>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return ScheduleListNotifier(sharedPreferences);
});