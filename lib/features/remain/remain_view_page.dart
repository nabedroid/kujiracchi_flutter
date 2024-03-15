import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/count_display_widget.dart';
import 'package:kujiracchi_dart/common_widget/application_time.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/features/config/config.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

/// 選択されているスケジュールを公開する
final _remainPageSelectedScheduleProvider = Provider.autoDispose<Schedule>((ref) {
  final scheduleList = ref.watch(scheduleListProvider);
  final remainPageState = ref.watch(remainPageStateProvider);

  return scheduleList.getSchedule(id: remainPageState.selectedScheduleId!);
});

/// 選択されているタスクを公開する
final _remainViewSelectedTaskProvider = Provider.autoDispose<ScheduleTask>((ref) {

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

class RemainViewPage extends ConsumerStatefulWidget {
  const RemainViewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _RemainViewPageState();
  }
}

class _RemainViewPageState extends ConsumerState<RemainViewPage> {

  late final ScheduleList _scheduleList;

  @override
  void initState() {
    super.initState();
    _scheduleList = ref.read(scheduleListProvider);
  }

  @override
  Widget build(BuildContext context) {

    final schedule = ref.watch(_remainPageSelectedScheduleProvider);
    final config = ref.watch(configProvider);
    final applicationDateTime = ref.watch(applicationTimerProvider);
    final task = ref.watch(_remainViewSelectedTaskProvider);
    final stopTime = ref.watch(_remainViewStopTimeProvider);

    // 残り時間の計算

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // タイトル、戻るボタン
          Row(
            children: [
              Expanded(
                child: Text(
                  task.memo,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          // アプリ時間
          Text(
            '1', //applicationDateTime.toIso8601String(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // 上下ボタン、残り時間、上下ボタン
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 上下ボタン
                _RemainViewScheduleUpDownButtons(
                  onUpPressed: () {
                    int index = -1;
                    schedule.tasks.forEachIndexed((i, element) {
                      if (element.id == task.id) {
                        index = i;
                      }
                    });
                    if (0 < index) {
                      ref.read(remainPageStateProvider.notifier).selectedTaskId = schedule.tasks.elementAt(index - 1).id;
                    }
                  },
                  onDownPressed: () {
                    int index = -1;
                    schedule.tasks.forEachIndexed((i, element) {
                      if (element.id == task.id) {
                        index = i;
                      }
                    });
                    if (0 <= index && index + 1 < schedule.tasks.length) {
                      ref.read(remainPageStateProvider.notifier).selectedTaskId = schedule.tasks.elementAt(index + 1).id;
                    }

                  },
                ),
                // 残り時間
                Expanded(child: CountDisplayWidget(
                  count: stopTime - applicationDateTime.millisecondsSinceEpoch, //stopTime - applicationDateTime.millisecondsSinceEpoch,
                  decimalDigits: config.remainDecimalDigits,
                  isCountUp: false,
                )),
                // 上下ボタン
                //_RemainViewScheduleUpDownButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                  icon: Icon(Icons.arrow_drop_up),
                  onPressed: onUpPressed,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: IconButton(
                icon: Icon(Icons.arrow_drop_down),
                onPressed: onDownPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
