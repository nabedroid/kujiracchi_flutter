import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';

final remainPageSelectedScheduleProvider = Provider.autoDispose<Schedule?>((ref) {
  Schedule? response;
  final scheduleList = ref.watch(scheduleListProvider);
  final remainPageStatus = ref.watch(remainPageStateProvider);

  if (remainPageStatus.selectedScheduleId != null) {
    response = scheduleList.schedules.singleWhere((element) => element.id == remainPageStatus.selectedScheduleId);
  }

  return response;
});