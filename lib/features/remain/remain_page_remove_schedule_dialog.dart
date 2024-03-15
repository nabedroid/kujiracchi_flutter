import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';

/// スケジュール削除確認ダイアログを表示する
/// ダイアログでOKが押されたらスケジュールを削除する
class RemainPageRemoveScheduleDialog extends ConsumerWidget {

  final String scheduleId;

  RemainPageRemoveScheduleDialog({Key? key, required this.scheduleId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSchedule = ref.read(scheduleListProvider).getSchedule(id: scheduleId);

    return AlertDialog(
        title: const Text('削除確認'),
        content: Text('${selectedSchedule.name}を削除しますか？'),
        actions:[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = selectedSchedule.id;
              ref.read(remainPageStateProvider.notifier).selectedScheduleId = null;
              ref.read(remainPageStateProvider.notifier).selectedTaskId = null;
              ref.read(scheduleListProvider.notifier).removeSchedule(id);
              if (ref.read(scheduleListProvider).schedules.isNotEmpty) {
                ref.read(remainPageStateProvider.notifier).selectedScheduleId = ref.read(scheduleListProvider).schedules.first.id;
              }
              Navigator.of(context).pop();
            },
            child: const Text('削除'),
          ),
        ]
    );
  }
}