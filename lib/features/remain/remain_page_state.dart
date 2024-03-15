import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RemainPageMode {
  display,
  edit,
}

class RemainPageState {
  final String? newScheduleName;
  final String? selectedScheduleId;
  final String? selectedTaskId;
  final RemainPageMode mode;

  const RemainPageState._({
    required this.newScheduleName,
    required this.selectedScheduleId,
    required this.selectedTaskId,
    required this.mode,
  });

  factory RemainPageState({
    required String? newScheduleName,
    required String? selectedScheduleId,
    required String? selectedTaskId,
    required RemainPageMode? mode,
  }) {
    return RemainPageState._(
      newScheduleName: newScheduleName,
      selectedScheduleId: selectedScheduleId,
      selectedTaskId: selectedTaskId,
      mode: mode ?? RemainPageMode.display,
    );
  }

  RemainPageState copyWith({
    required String? selectedScheduleId,
    required String? selectedTaskId,
    String? newScheduleName,
    RemainPageMode? mode,
  }) {
    return RemainPageState._(
      newScheduleName: newScheduleName,
      selectedScheduleId: selectedScheduleId,
      selectedTaskId: selectedTaskId,
      mode: mode ?? this.mode,
    );
  }
}

class RemainPageStateNotifier extends StateNotifier<RemainPageState> {
  RemainPageStateNotifier()
      : super(RemainPageState(
          newScheduleName: null,
          selectedScheduleId: null,
          selectedTaskId: null,
          mode: RemainPageMode.display,
        ));

  set newScheduleName(String? scheduleName) => state = state.copyWith(
      newScheduleName: scheduleName,
      selectedScheduleId: state.selectedScheduleId,
      selectedTaskId: state.selectedScheduleId
  );

  set selectedScheduleId(String? scheduleId) => state =
      state.copyWith(selectedScheduleId: scheduleId, selectedTaskId: null);

  set selectedTaskId(String? taskId) => state = state.copyWith(
      selectedScheduleId: state.selectedScheduleId, selectedTaskId: taskId);

  set mode(RemainPageMode mode) => state = state.copyWith(
    selectedScheduleId: state.selectedScheduleId,
    selectedTaskId: state.selectedTaskId,
    mode: mode,
  );
}

final remainPageStateProvider =
    StateNotifierProvider.autoDispose<RemainPageStateNotifier, RemainPageState>(
        (ref) {
  return RemainPageStateNotifier();
});
