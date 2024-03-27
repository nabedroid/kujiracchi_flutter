import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_listview_widget.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_navigationrail.dart';

import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

final _editedScheduleNameProvider = StateProvider<bool>((ref) => false);

class RemainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController scheduleNameController = TextEditingController();
    final bool isEditedScheduleName = ref.watch(_editedScheduleNameProvider);
    final ScheduleList scheduleList = ref.watch(scheduleListProvider);
    final RemainPageState remainPageState = ref.watch(remainPageStateProvider);
    final Schedule? selectedSchedule =
        remainPageState.selectedScheduleId == null
            ? null
            : scheduleList.getSchedule(id: remainPageState.selectedScheduleId!);
    final remainPageListView = RemainPageScheduleTaskListViewWidget();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Remain'),
      ),
      body: Row(
        children: [
          // 画面左のスケジュール管理メニュー
          RemainPageNavigationRail(),
          // 区切り線
          const VerticalDivider(thickness: 1, width: 1),
          // 画面右側のスケジュール表示領域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // スケジュール情報のヘッダー
                Row(
                  children: [
                    // スケジュール名
                    Expanded(
                      flex: 5,
                      // 長押しで編集状態へ
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: isEditedScheduleName
                              // 編集状態の場合はテキストフィールド
                              ? Focus(
                                  onFocusChange: (focused) {
                                    if (focused) {
                                      scheduleNameController.text = scheduleList
                                          .getSchedule(
                                              id: remainPageState
                                                  .selectedScheduleId!)
                                          .name;
                                    } else {
                                      ref
                                          .read(scheduleListProvider.notifier)
                                          .updateSchedule(
                                              remainPageState
                                                  .selectedScheduleId!,
                                              name:
                                                  scheduleNameController.text);
                                      _toggledEditedScheduleName(
                                          ref: ref, isEdited: false);
                                    }
                                  },
                                  child: TextField(
                                    autofocus: true,
                                    controller: scheduleNameController,
                                    inputFormatters: [LengthLimitingTextInputFormatter(15)],
                                  ),
                                )
                              // 通常時はテキスト
                              : GestureDetector(
                                  onLongPress: () => _toggledEditedScheduleName(
                                      ref: ref, isEdited: true),
                                  child: Text(
                                    selectedSchedule?.name ?? ' ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Viewボタン
                    Expanded(
                      flex: 1,
                      child: IconButton.outlined(
                        icon: Icon(Icons.fullscreen_outlined),
                        onPressed: () {
                          _showView(remainPageState: remainPageState, context: context, scheduleList: scheduleList, ref: ref);
                        },
                      ),
                    )
                  ],
                ),
                Divider(),
                // タスクのリスト表示
                Expanded(child: remainPageListView),
              ],
            ),
          ),
        ],
      ),
      // タスク追加
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 何れかのスケジュールが選択状態のときにタスク追加
          if (remainPageState.selectedScheduleId != null) {
            ScheduleTask newTask = ScheduleTask(
              memo: '新しいタスク',
              time: '00:00:00',
            );
            ref.read(scheduleListProvider.notifier).addTask(
                remainPageState.selectedScheduleId!,
                newTask,
            );
            // 追加したタスクを選択状態にする
            remainPageListView.toggledEditedTask(ref: ref, taskId: newTask.id);
          }
        },
      ),
    );
  }

  void _toggledEditedScheduleName({
    required WidgetRef ref,
    bool isEdited = false,
  }) {
    // タスク選択状態を解除
    ref.read(remainPageStateProvider.notifier).selectedTaskId = null;
    // 編集状態を更新
    ref.read(_editedScheduleNameProvider.notifier).state = isEdited;
  }

  void _showView({
    required RemainPageState remainPageState,
    required BuildContext context,
    required ScheduleList scheduleList,
    required WidgetRef ref,
  }) {
    // スケジュールが選択中かつタスクが1つ以上設定されているならView画面を開く
    if (remainPageState.selectedScheduleId != null) {
      if (remainPageState.selectedTaskId != null) {
        Navigator.of(context).pushNamed('/remain_view');
      } else {
        // タスクが未選択の場合は先頭のタスクを選択して開く
        final schedule =
            scheduleList.getSchedule(id: remainPageState.selectedScheduleId!);
        if (schedule.tasks.isNotEmpty) {
          Navigator.of(context).pushNamed('/remain_view');
          ref.read(remainPageStateProvider.notifier).selectedTaskId =
              schedule.tasks.first.id;
        }
      }
    }
  }
}
