import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/common_widget/setting_application_time_dialog.dart';

class DigitalClockWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationDateTime = ref.watch(applicationTimerProvider);

    return SizedBox(
      width: 10000,
      height: 10000,
      child: FittedBox(
        fit: BoxFit.fill,
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SettingApplicationTimeDialog();
              },
            );
          },
          child: Text(StringUtil.dateTimeToHHMMSS(applicationDateTime)),
        ),
      ),
    );
  }
}
