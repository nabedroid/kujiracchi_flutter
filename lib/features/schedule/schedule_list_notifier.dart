import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

class ScheduleListNotifier extends StateNotifier<ScheduleList> {
  final SharedPreferences sharedPreference;

  ScheduleListNotifier(this.sharedPreference)
      : super(ScheduleList.fromSharedPreferences(sharedPreference)) {
  }

  void addSchedule(Schedule schedule) {
    state = state.copyWith(
      schedules: [...state.schedules, schedule],
      updateAt: DateTime.now(),
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void addTask(String scheduleId, ScheduleTask task) {
    final now = DateTime.now();
    state = state.copyWith(
      schedules: state.schedules.map((schedule) {
        if (schedule.id == scheduleId) {
          return schedule.copyWith(
            tasks: [...schedule.tasks, task],
            updateAt: now,
          );
        } else {
          return schedule;
        }
      }),
      updateAt: now,
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void removeSchedule(String scheduleId) {
    state = state.copyWith(
      schedules: state.schedules.where((schedule) => schedule.id != scheduleId),
      updateAt: DateTime.now(),
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void removeTask(String scheduleId, String taskId) {
    final now = DateTime.now();
    state = state.copyWith(
      schedules: state.schedules.map((schedule) => schedule.id == scheduleId
          ? schedule.copyWith(
              tasks: schedule.tasks.where((task) => task.id != taskId),
              updateAt: now,
            )
          : schedule),
      updateAt: now,
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void updateSchedule(String scheduleId, {String? name}) {
    final now = DateTime.now();
    state = state.copyWith(
      schedules: state.schedules.map((schedule) {
        if (schedule.id == scheduleId) {
          return schedule.copyWith(
            name: name,
            updateAt: now,
          );
        } else {
          return schedule;
        }
      }),
      updateAt: now,
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void updateTask(String scheduleId, String taskId,
      {String? memo, String? time, bool? auto}) {
    final now = DateTime.now();
    state = state.copyWith(
      schedules: state.schedules.map((schedule) {
        if (schedule.id == scheduleId) {
          return schedule.copyWith(
            tasks: schedule.tasks.map((task) {
              if (task.id == taskId) {
                return task.copyWith(
                    memo: memo, time: time, auto: auto, updateAt: now);
              } else {
                return task;
              }
            }),
            updateAt: now,
          );
        } else {
          return schedule;
        }
      }),
      updateAt: now,
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void reorderSchedule(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex = newIndex - 1;
    }
    final newSchedules = state.schedules.toList();
    final schedule = newSchedules.removeAt(oldIndex);
    newSchedules.insert(newIndex, schedule);
    state = state.copyWith(
      schedules: newSchedules,
      updateAt: DateTime.now(),
    );
    sharedPreference.setString('schedules', state.toString());
  }

  void reorderTask(String scheduleId, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex = newIndex - 1;
    }
    final newTasks = state.getSchedule(id: scheduleId).tasks.toList();
    final task = newTasks.removeAt(oldIndex);
    newTasks.insert(newIndex, task);
    state = state.copyWith(
      schedules: state.schedules.map((schedule) => schedule.id == scheduleId
          ? schedule.copyWith(tasks: newTasks)
          : schedule),
      updateAt: DateTime.now(),
    );
    sharedPreference.setString('schedules', state.toString());
  }
}
