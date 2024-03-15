import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_task_dialog.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

class RemainPageScheduleTaskListViewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleList = ref.watch(scheduleListProvider);
    final remainPageState = ref.watch(remainPageStateProvider);

    // 並び替えが可能なリストビュー
    return ReorderableListView.builder(
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
        final selectedSchedule =
            scheduleList.getSchedule(id: remainPageState.selectedScheduleId!);
        final task = selectedSchedule.tasks.elementAt(index);
        return Row(
          key: Key(task.id),
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                key: Key(task.id),
                child: ListTile(
                  // タップされたアイテムを選択状態にする
                  onTap: () {
                    ref.read(remainPageStateProvider.notifier).selectedTaskId =
                        task.id;
                  },
                  // ロングタップされたら編集モードに移行
                  onLongPress: () {
                    ref.read(remainPageStateProvider.notifier).mode =
                        RemainPageMode.edit;
                  },
                  // 選択されているアイテムの背景色を変更
                  tileColor: remainPageState.selectedTaskId == task.id
                      ? Colors.lightGreen
                      : Theme.of(context).colorScheme.background,
                  // 並び替えアイコン
                  leading: remainPageState.mode == RemainPageMode.display
                      ? ReorderableDragStartListener(
                          index: index,
                          child: Icon(Icons.drag_handle),
                        )
                      :             Icon(Icons.remove),
                  // メモ、時間、自動送りの表示
                  title: Row(
                    children: [
                      Expanded(flex: 1, child: Text(task.memo)),
                      Expanded(flex: 1, child: Text(task.time)),
                      Expanded(
                          flex: 1,
                          child: Icon(task.auto ? Icons.auto_mode_outlined : null)),
                    ],
                  ),
                  trailing: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.edit),
                      Icon(Icons.delete_outline),
                    ],
                  ),
                ),
              
                // trailing: PopupMenuButton(
                //   // initialValue: value,
                //   onSelected: (item) {},
                //   itemBuilder: (BuildContext context) {
                //     return <PopupMenuItem<_TaskPopupMenuItem>>[
                //       PopupMenuItem(
                //         value: _TaskPopupMenuItem.edit,
                //         child: ListTile(
                //             leading: Icon(Icons.edit), title: Text('Edit')),
                //         onTap: () async {
                //           ScheduleTask? editedTask = await showDialog(
                //               context: context,
                //               builder: (context) {
                //                 return TaskDialog(
                //                     mode: TaskDialogMode.edit, taskId: task.id);
                //               });
                //           if (editedTask != null) {
                //             ref.read(scheduleListProvider.notifier).updateTask(
                //                   remainPageState.selectedScheduleId!,
                //                   editedTask.id,
                //                   memo: editedTask.memo,
                //                   time: editedTask.time,
                //                   auto: editedTask.auto,
                //                 );
                //           }
                //         },
                //       ),
                //       PopupMenuItem(
                //         value: _TaskPopupMenuItem.remove,
                //         child: ListTile(
                //             leading: Icon(Icons.delete_outline),
                //             title: Text('Remove')),
                //         onTap: () async {
                //           showDialog(
                //               context: context,
                //               builder: (context) {
                //                 return AlertDialog(
                //                   title: const Text('削除確認'),
                //                   content: Text('${task.memo}を削除しますか？'),
                //                   actions: [
                //                     ElevatedButton(
                //                       onPressed: () => Navigator.of(context).pop(),
                //                       child: const Text('キャンセル'),
                //                     ),
                //                     ElevatedButton(
                //                         onPressed: () {
                //                           ref
                //                               .read(scheduleListProvider.notifier)
                //                               .removeTask(
                //                                   selectedSchedule.id, task.id);
                //                           Navigator.of(context).pop();
                //                         },
                //                         child: const Text('OK')),
                //                   ],
                //                 );
                //               });
                //         },
                //       ),
                //     ];
                //   },
                // ),
              ),
            ),
          ],
        );
      },
    );
  }
}
