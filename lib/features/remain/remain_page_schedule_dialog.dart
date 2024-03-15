import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';

enum ScheduleDialogMode {
  add,
  edit,
  remove,
}

class RemainPageScheduleDialog extends ConsumerWidget {
  final ScheduleDialogMode mode;
  final _formKey = GlobalKey<FormState>();

  RemainPageScheduleDialog({Key? key, required this.mode, String? scheduleId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final textEditingController = TextEditingController();

    return AlertDialog(
      title: const Text('スケジュール名'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: textEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'スケジュール名を入力して下さい。';
                } else if (value.length > 20) {
                  return '20文字以内で入力して下さい。';
                } else if (ref.read(scheduleListProvider).schedules.map((schedule) => schedule.name).contains(value)) {
                  return 'スケジュール名が重複しています。';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // スケジュール追加
              final newSchedule = Schedule(name: textEditingController.text);
              ref.read(scheduleListProvider.notifier).addSchedule(newSchedule);
              // スケジュールを選択状態にする
              ref.read(remainPageStateProvider.notifier).selectedScheduleId = newSchedule.id;
              Navigator.of(context).pop();
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
