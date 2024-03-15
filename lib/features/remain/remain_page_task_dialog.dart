import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';
import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

class _TaskDialogState {
  final String memo;
  final int h;
  final int m;
  final int s;
  final bool auto;

  const _TaskDialogState(
      {this.memo = '', this.h = 0, this.m = 0, this.s = 0, this.auto = true});

  factory _TaskDialogState.fromTask(ScheduleTask task) {
    final (h, m, s) = StringUtil.hmsToInt(task.time);
    return _TaskDialogState(memo: task.memo, h: h, m: m, s: s, auto: task.auto);
  }

  _TaskDialogState copyWith(
      {String? memo, int? h, int? m, int? s, bool? auto}) {
    return _TaskDialogState(
      memo: memo ?? this.memo,
      h: h ?? this.h,
      m: m ?? this.m,
      s: s ?? this.s,
      auto: auto ?? this.auto,
    );
  }
}

class _TaskDialogStateNotifier extends StateNotifier<_TaskDialogState> {
  _TaskDialogStateNotifier([ScheduleTask? task])
      : super(task == null
            ? _TaskDialogState()
            : _TaskDialogState.fromTask(task));

  set memo(String memo) => state = state.copyWith(memo: memo);
  set h(int h) => state = state.copyWith(h: h);
  set m(int m) => state = state.copyWith(m: m);
  set s(int s) => state = state.copyWith(s: s);
  set auto(bool auto) => state = state.copyWith(auto: auto);
}

final _taskDialogStateProvider = StateNotifierProvider.autoDispose
    .family<_TaskDialogStateNotifier, _TaskDialogState, String?>((ref, taskId) {
  if (taskId == null) {
    return _TaskDialogStateNotifier();
  } else {
    final task = ref.read(scheduleListProvider).getScheduleTask(taskId: taskId);
    return _TaskDialogStateNotifier(task);
  }
});

enum TaskDialogMode {
  add,
  edit,
}

class TaskDialog extends ConsumerStatefulWidget {
  final TaskDialogMode mode;
  final String? taskId;

  const TaskDialog({Key? key, required this.mode, this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return TaskDialogState();
  }
}

class TaskDialogState extends ConsumerState<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final ScheduleTask? task;
  late final FixedExtentScrollController hourCtrl;
  late final FixedExtentScrollController minCtrl;
  late final FixedExtentScrollController secCtrl;

  TaskDialogState() : super();

  @override
  void initState() {
    super.initState();

    if (widget.mode == TaskDialogMode.add) {
      task = null;
      hourCtrl = FixedExtentScrollController();
      minCtrl = FixedExtentScrollController();
      secCtrl = FixedExtentScrollController();
    } else {
      task = ref
          .read(scheduleListProvider)
          .getScheduleTask(taskId: widget.taskId!);
      final (h, m, s) = StringUtil.hmsToInt(task!.time);
      hourCtrl = FixedExtentScrollController(initialItem: h);
      minCtrl = FixedExtentScrollController(initialItem: m);
      secCtrl = FixedExtentScrollController(initialItem: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeWidgetSize = Size(
      Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.5,
      Theme.of(context).textTheme.bodyMedium!.fontSize! * 3,
    );
    final timeItemExtent = Theme.of(context).textTheme.bodyMedium!.fontSize!;
    final _TaskDialogState state =
        ref.watch(_taskDialogStateProvider(widget.taskId));

    return AlertDialog(
        title: widget.mode == TaskDialogMode.add
            ? const Text('タスク追加')
            : const Text('タスク修正'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: state.memo,
                autofocus: true,
                //controller: memoCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'メモを入力して下さい。';
                  } else if (value.length > 20) {
                    return 'メモは20文字以内で入力して下さい。';
                  }
                  return null;
                },
                // TODO: onChangedでstateの更新をしているので、入力の旅にbuildされてコスパが悪い、onFieldCommittedに処理を回したいが何故か当該イベントが発生しないので一先ずここに実装する
                onChanged: (text) => ref
                    .read(_taskDialogStateProvider(widget.taskId).notifier)
                    .memo = text,
              ),
              Row(
                //mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: timeWidgetSize.width,
                    height: timeWidgetSize.height,
                    child: ListWheelScrollView.useDelegate(
                      controller: hourCtrl,
                      physics: FixedExtentScrollPhysics(),
                      itemExtent: timeItemExtent,
                      childDelegate: ListWheelChildLoopingListDelegate(
                        children: List<Widget>.generate(24,
                            (index) => Center(child: Text(index.toString()))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: timeWidgetSize.width,
                    height: timeWidgetSize.height,
                    child: ListWheelScrollView.useDelegate(
                      controller: minCtrl,
                      physics: FixedExtentScrollPhysics(),
                      itemExtent: timeItemExtent,
                      childDelegate: ListWheelChildLoopingListDelegate(
                        children: List<Widget>.generate(60,
                            (index) => Center(child: Text(index.toString()))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: timeWidgetSize.width,
                    height: timeWidgetSize.height,
                    child: ListWheelScrollView.useDelegate(
                      controller: secCtrl,
                      physics: FixedExtentScrollPhysics(),
                      itemExtent: timeItemExtent,
                      childDelegate: ListWheelChildLoopingListDelegate(
                        children: List<Widget>.generate(60,
                            (index) => Center(child: Text(index.toString()))),
                      ),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: state.auto,
                title: const Text('自動送り'),
                onChanged: (bool value) {
                  print('switch taskId = ${task.hashCode}');
                  ref
                      .read(_taskDialogStateProvider(widget.taskId).notifier)
                      .auto = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScheduleTask result;
                  int h = hourCtrl.selectedItem % 24;
                  int m = minCtrl.selectedItem % 60;
                  int s = secCtrl.selectedItem % 60;
                  if (widget.mode == TaskDialogMode.add) {
                    result = ScheduleTask(
                        memo: state.memo,
                        time: StringUtil.hmsToString(h, m, s),
                        auto: state.auto);
                  } else {
                    result = task!.copyWith(
                        memo: state.memo,
                        time: StringUtil.hmsToString(h, m, s),
                        auto: state.auto);
                  }
                  Navigator.of(context).pop(result);
                }
              },
              child: const Text('OK')),
        ]);
  }
}
