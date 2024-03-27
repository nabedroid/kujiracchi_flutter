import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/setting_time_dialog.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

final _editTaskIdProvider = StateProvider.autoDispose<String?>((ref) => null);

class RemainPageScheduleTaskListViewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listViewFocusNode = FocusNode();
    final scheduleList = ref.watch(scheduleListProvider);
    final remainPageState = ref.watch(remainPageStateProvider);

    // 並び替えが可能なリストビュー
    return Focus(
      focusNode: listViewFocusNode,
      child: GestureDetector(
        onTap: () {
          // リスト外を選択したら編集状態を解除
          toggledEditedTask(ref: ref);
        },
        child: ReorderableListView.builder(
          // デフォルトの並び替えボタンを非表示
          buildDefaultDragHandles: false,
          // 並び替え終了時のイベント処理
          onReorder: (oldIndex, newIndex) {
            ref.read(scheduleListProvider.notifier).reorderTask(
                  remainPageState.selectedScheduleId!,
                  oldIndex,
                  newIndex,
                );
          },
          // リストに表示するタスク数
          // スケジュールが未選択の場合は0を設定
          itemCount: remainPageState.selectedScheduleId != null
              ? scheduleList
                  .getSchedule(id: remainPageState.selectedScheduleId!)
                  .tasks
                  .length
              : 0,
          // リストの項目ごとにアイテムを作成
          itemBuilder: (context, index) {
            return _buildListItemBuilder(
              index: index,
              ref: ref,
              context: context,
              scheduleList: scheduleList,
              remainPageState: remainPageState,
            );
          },
        ),
      ),
    );
  }

  Widget _buildListItemBuilder({
    required int index,
    required BuildContext context,
    required ScheduleList scheduleList,
    required RemainPageState remainPageState,
    required WidgetRef ref,
  }) {
    final selectedSchedule =
        scheduleList.getSchedule(id: remainPageState.selectedScheduleId!);
    final task = selectedSchedule.tasks.elementAt(index);
    final editTaskId = ref.watch(_editTaskIdProvider);
    final isEdited = editTaskId == task.id;
    final controller = TextEditingController(text: task.memo);

    return Card(
      key: Key(task.id),
      child: ListTile(
        // タップされたアイテムを選択状態にする
        onTap: () => toggledSelectedTask(taskId: task.id, ref: ref),
        // ロングタップされたら編集モードに移行
        onLongPress: () => toggledEditedTask(taskId: task.id, ref: ref),
        // 選択されているアイテムの背景色を変更
        tileColor: remainPageState.selectedTaskId == task.id
            ? Colors.lightGreen
            : Theme.of(context).colorScheme.background,
        // 編集中の場合は削除ボタン、通常の場合は並び替えボタン
        leading: isEdited
            ? IconButton(
                icon: Icon(Icons.remove),
                onPressed: () async {
                  // 削除確認ダイアログを表示
                  final result =
                      await _showRemoveTaskDialog(context: context, task: task);
                  if (result != null) {
                    _removeTask(
                      ref: ref,
                      remainPageState: remainPageState,
                      task: task,
                    );
                  }
                },
              )
            : ReorderableDragStartListener(
                index: index,
                child: Icon(Icons.drag_handle),
              ),
        // メモ、時間、自動送りの表示
        title: Row(
          children: [
            // メモ
            // 編集状態の際はテキストフィールドで表示する
            Expanded(
              flex: 2,
              // テキストフィールドの初期値やProviderへの値更新はフォーカスイベント内で実施
              child: isEdited
                  ? Focus(
                      onFocusChange: (focused) {
                        if (focused) {
                          controller.text = task.memo;
                        } else {
                          ref.read(scheduleListProvider.notifier).updateTask(
                                remainPageState.selectedScheduleId!,
                                task.id,
                                memo: controller.text,
                              );
                        }
                      },
                      child: TextField(
                        autofocus: true,
                        controller: controller,
                        // メモの入力可能値を15文字に抑制
                        inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      ),
                    )
                  : _buildMemoTimeText(context, task.memo),
            ),
            // 時間
            Expanded(
              flex: 1,
              // 編集状態の際はボタン表示
              child: isEdited
                  ? ElevatedButton(
                      onPressed: () async {
                        // 時間設定ダイアログを呼び出す
                        final result =
                            await _showSettingTimeDialog(context: context);
                        // OKボタンが押されたらタスクを更新する
                        if (result != null) {
                          _updateTaskTime(
                              ref: ref,
                              remainPageState: remainPageState,
                              task: task,
                              hour: result.hour,
                              min: result.min,
                              sec: result.sec);
                        }
                      },
                      child: Text(task.time),
                    )
                  : _buildMemoTimeText(context, task.time),
            ),
            Expanded(
              flex: 1,
              child: Switch(
                value: task.auto,
                onChanged: isEdited
                    ? (bool value) => _toggledTaskAuto(
                          ref: ref,
                          remainPageState: remainPageState,
                          task: task,
                          auto: value,
                        )
                    : (bool value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  ConstrainedBox _buildMemoTimeText(BuildContext context, String text) {
    return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: Theme.of(context)
                          .textTheme
                          .displayLarge!
                          .fontSize!),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerLeft,
                    child: Text(text),
                  ),
                );
  }

  /// タスクを削除する
  void _removeTask({
    required WidgetRef ref,
    required RemainPageState remainPageState,
    required ScheduleTask task,
  }) {
    ref.read(scheduleListProvider.notifier).removeTask(
          remainPageState.selectedScheduleId!,
          task.id,
        );
  }

  /// 削除確認ダイアログを表示する
  Future<dynamic> _showRemoveTaskDialog({
    required BuildContext context,
    required ScheduleTask task,
  }) {
    return showDialog<dynamic>(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('削除確認'),
            content: Text('${task.memo}を削除しますか？'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('OK'),
              ),
            ]);
      },
    );
  }

  /// 時間設定ダイアログを表示する
  Future _showSettingTimeDialog({required BuildContext context}) {
    return showDialog(
        context: context,
        builder: (context) {
          return SettingTimeDialog();
        });
  }

  /// タスクの自動送りを切り替える
  void _toggledTaskAuto({
    required WidgetRef ref,
    required RemainPageState remainPageState,
    required ScheduleTask task,
    required bool auto,
  }) {
    ref.read(scheduleListProvider.notifier).updateTask(
          remainPageState.selectedScheduleId!,
          task.id,
          auto: auto,
        );
  }

  /// タスクの時間を更新する
  void _updateTaskTime({
    required WidgetRef ref,
    required RemainPageState remainPageState,
    required ScheduleTask task,
    required int hour,
    required int min,
    required int sec,
  }) {
    // タスクの時間を更新する
    ref.read(scheduleListProvider.notifier).updateTask(
          remainPageState.selectedScheduleId!,
          task.id,
          time: StringUtil.hmsToString(hour, min, sec),
        );
  }

  /// 選択中のタスクを変更する
  void toggledSelectedTask({
    String? taskId,
    required WidgetRef ref,
  }) {
    ref.read(remainPageStateProvider.notifier).selectedTaskId = taskId;
  }

  /// 編集中のタスクを変更する
  void toggledEditedTask({
    String? taskId,
    required WidgetRef ref,
  }) {
    ref.read(_editTaskIdProvider.notifier).state = taskId;
  }
}
