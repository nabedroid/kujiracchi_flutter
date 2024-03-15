import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/features/remain/remain_page_selected_schedule_provider.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';

class RemainPageRenameScheduleDialog extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = TextEditingController();
    textEditingController.text = ref.read(remainPageSelectedScheduleProvider)!.name;

    return AlertDialog(
      title: const Text('スケジュール名変更'),
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
              // スケジュール変更
              final id = ref.read(remainPageStateProvider).selectedScheduleId!;
              final renameSchedule = ref.read(scheduleListProvider.notifier).updateSchedule(id, name: textEditingController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('変更'),
        ),
      ],
    );
  }
}
