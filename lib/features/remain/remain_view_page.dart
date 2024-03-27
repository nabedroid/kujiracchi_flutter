import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/count_display_widget.dart';
import 'package:kujiracchi_dart/common_widget/application_time.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/common_widget/kujira_widget.dart';
import 'package:kujiracchi_dart/features/config/config.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

/// 選択されているスケジュールを公開する
final _remainPageSelectedScheduleProvider =
    Provider.autoDispose<Schedule>((ref) {
  final scheduleList = ref.watch(scheduleListProvider);
  final remainPageState = ref.watch(remainPageStateProvider);

  return scheduleList.getSchedule(id: remainPageState.selectedScheduleId!);
});

/// 選択されているタスクを公開する
final _remainViewSelectedTaskProvider =
    Provider.autoDispose<ScheduleTask>((ref) {
  final scheduleList = ref.watch(scheduleListProvider);
  final remainPageState = ref.watch(remainPageStateProvider);

  return scheduleList.getScheduleTask(taskId: remainPageState.selectedTaskId!);
});

/// 選択されているタスクの終了時刻を公開する
final _remainViewStopTimeProvider = Provider.autoDispose<int>((ref) {
  final applicationDateTime = ref.watch(applicationTimeProvider);
  final selectedTask = ref.watch(_remainViewSelectedTaskProvider);
  final (h, m, s) = StringUtil.hmsToInt(selectedTask.time);
  // 現在の日付にタスクの時、分、秒を上書いて終了時刻とする
  DateTime stopTime = applicationDateTime.copyWith(
    hour: h,
    minute: m,
    second: s,
    millisecond: 0,
    microsecond: 0,
  );
  // 終了時刻が現在時刻より前の時刻だった場合は日付を1日加算して補正する
  // 現在時刻23:00:00、終了時刻22:00:00なら、終了時刻に24時間（1日）加算して46:00:00にするイメージ
  if (applicationDateTime.isAfter(stopTime)) {
    stopTime = stopTime.add(Duration(days: 1));
  }
  return stopTime.millisecondsSinceEpoch;
});

/// 選択中タスクまでの残り時間を公開する
final _remainTimeProvider = StateProvider.autoDispose<int>((ref) {
  final applicationDateTime = ref.watch(applicationTimerProvider);
  final stopTime = ref.watch(_remainViewStopTimeProvider);

  return stopTime - applicationDateTime.millisecondsSinceEpoch;
});

/// 残り時間が0秒以下か公開する
/// 0秒以下の場合は次のタスクへ自動送りする
final _isTimeOverProvider = StateProvider.autoDispose((ref) {
  final remainTime = ref.watch(_remainTimeProvider);
  // タイムオーバーになった場合に自動送りを行う
  ref.listenSelf((pre, next) {
    if (next == true) {
      // タイムオーバーになった場合
      final task = ref.read(_remainViewSelectedTaskProvider);
      if (task.auto) {
        // 自動送り機能が有効な場合
        final schedule = ref.read(_remainPageSelectedScheduleProvider);
        int index = schedule.getTaskIndex(task.id)!;
        if (0 <= index && index + 1 < schedule.tasks.length) {
          // 次のタスクが存在する場合は選択中タスクを更新する
          ref.read(remainPageStateProvider.notifier).selectedTaskId =
              schedule.tasks.elementAt(index + 1).id;
        }
      }
    }
  });

  return remainTime <= 0;
});

/// タスクの残り時間を全画面表示する
class RemainViewPage extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 選択中のスケジュール
    final schedule = ref.watch(_remainPageSelectedScheduleProvider);
    // 選択中のタスク
    final task = ref.watch(_remainViewSelectedTaskProvider);
    // 残り時間が0以下かのフラグ
    final isTimeOver = ref.watch(_isTimeOverProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // タイトル、くじらボタン
          Row(
            children: [
              // タイトル（タスクのメモ）
              Expanded(
                child: Text(
                  task.memo,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              // くじらボタン
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: KujiraWidget(
                  onSlided: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          // アプリ時間、タイムオーバー
          Stack(
            children: [
              // タスクの設定時間
              Text(
                '終 ${task.time}', //applicationDateTime.toIso8601String(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              // タイムオーバー時の"オーバー"テキスト
              if (isTimeOver)
                Center(
                  child: Text('オーバー',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(color: Colors.red)),
                ),
            ],
          ),
          // 上下ボタン、残り時間、上下ボタン
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 上下ボタン
                _RemainViewScheduleUpDownButtons(
                  onUpPressed: () => _onUpPressed(
                      selectedSchedule: schedule, selectedTask: task, ref: ref),
                  onDownPressed: () => _onDownPressed(
                      selectedSchedule: schedule, selectedTask: task, ref: ref),
                ),
                // 残り時間
                Expanded(
                  child: _RemainViewTime(),
                ),
                // 上下ボタン
                //_RemainViewScheduleUpDownButtons(),
                _RemainViewScheduleUpDownButtons(
                  onUpPressed: () => _onUpPressed(
                      selectedSchedule: schedule, selectedTask: task, ref: ref),
                  onDownPressed: () => _onDownPressed(
                      selectedSchedule: schedule, selectedTask: task, ref: ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 上ボタン押下時の処理
  /// 一つ前のタスクを選択状態にする
  void _onUpPressed({
    required Schedule selectedSchedule,
    required ScheduleTask selectedTask,
    required WidgetRef ref,
  }) {
    int index = -1;
    selectedSchedule.tasks.forEachIndexed((i, element) {
      if (element.id == selectedTask.id) {
        index = i;
      }
    });
    if (0 < index) {
      ref.read(remainPageStateProvider.notifier).selectedTaskId =
          selectedSchedule.tasks.elementAt(index - 1).id;
    }
  }

  /// 下ボタン押下時の処理
  /// 次のタスクを選択状態にする
  void _onDownPressed({
    required Schedule selectedSchedule,
    required ScheduleTask selectedTask,
    required WidgetRef ref,
  }) {
    int index = selectedSchedule.getTaskIndex(selectedTask.id) ?? -1;
    if (0 <= index && index + 1 < selectedSchedule.tasks.length) {
      ref.read(remainPageStateProvider.notifier).selectedTaskId =
          selectedSchedule.tasks.elementAt(index + 1).id;
    }
  }
}

/// 残り時間を表示する
/// 更新頻度が高いので別クラスとして切り出し
class _RemainViewTime extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainTime = ref.watch(_remainTimeProvider);
    final config = ref.watch(configProvider);
    return CountDisplayWidget(
      count: remainTime,
      decimalDigits: config.remainDecimalDigits,
      isCountUp: false,
    );
  }
}

/// 画面の両端に表示されるタスクを上下するボタン
class _RemainViewScheduleUpDownButtons extends StatelessWidget {
  final VoidCallback onUpPressed;
  final VoidCallback onDownPressed;

  const _RemainViewScheduleUpDownButtons({
    super.key,
    required this.onDownPressed,
    required this.onUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 180,
      ),
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: InkWell(
                onHover: null,
                hoverColor: Colors.transparent,
                child: IconButton(
                  constraints: BoxConstraints(),
                  //focusColor: Colors.transparent,
                  //hoverColor: Colors.transparent,
                  //splashColor: Colors.transparent,
                  //highlightColor: Colors.transparent,
                  icon: const Icon(Icons.arrow_drop_up),
                  onPressed: onUpPressed,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: onDownPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
