import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/application_time.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// 時間選択に使用するScrollViewライクなウィジェット
class _SettingApplicationTimeDialogListView extends ConsumerWidget {
  final List<int> items;
  final Size timeWidgetSize;
  final FixedExtentScrollController controller;
  final double fontSize;

  _SettingApplicationTimeDialogListView({
    required this.items,
    required this.timeWidgetSize,
    required this.controller,
    required this.fontSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: timeWidgetSize.width,
      height: timeWidgetSize.height,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        physics: FixedExtentScrollPhysics(),
        itemExtent: fontSize,
        childDelegate: ListWheelChildLoopingListDelegate(
            children: items.map((item) => Center(
                child: Text(item.toString(),
                    style: TextStyle(fontSize: fontSize)))).toList()),
      ),
    );
  }
}

class SettingApplicationTimeDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationTime = ref.read(applicationTimeProvider);
    // リストビューで使用するフォントサイズ
    final fontSize = Theme.of(context).textTheme.titleLarge!.fontSize!;
    // リストビューの上下数字の表示範囲を含めたサイズ
    final timeWidgetSize = Size(fontSize * 1.5, fontSize * 3);
    // アプリケーション時間の時、分、秒を取得し、リストビューの初期値に使用
    final hms = [
      applicationTime.hour,
      applicationTime.minute,
      applicationTime.second,
    ];
    // リストビューのアイテムが中途半端な位置で止まらない設定
    late final hourCtrl = FixedExtentScrollController(initialItem: hms[0]);
    late final minCtrl = FixedExtentScrollController(initialItem: hms[1]);
    late final secCtrl = FixedExtentScrollController(initialItem: hms[2]);

    return AlertDialog(
        title: const Text('時間設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 現在の端末時間を更新しながら表示
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final systemDateTime = ref.watch(systemTimerProvider);
                  final systemHHMMSS =
                      StringUtil.dateTimeToHHMMSS(systemDateTime);
                  return Text('端末時間  $systemHHMMSS');
                },
              ),
            ),
            Icon(Icons.keyboard_arrow_down),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SettingApplicationTimeDialogListView(
                    items: List<int>.generate(24, (i) => i),
                    timeWidgetSize: timeWidgetSize,
                    controller: hourCtrl,
                    fontSize: fontSize,
                ),
                Text(' : ', style: TextStyle(fontSize: fontSize)),
                _SettingApplicationTimeDialogListView(
                  items: List<int>.generate(60, (i) => i),
                  timeWidgetSize: timeWidgetSize,
                  controller: minCtrl,
                  fontSize: fontSize,
                ),
                Text(' : ', style: TextStyle(fontSize: fontSize)),
                _SettingApplicationTimeDialogListView(
                  items: List<int>.generate(60, (i) => i),
                  timeWidgetSize: timeWidgetSize,
                  controller: secCtrl,
                  fontSize: fontSize,
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
              onPressed: () => _onOkPressed(context, ref, hourCtrl, minCtrl, secCtrl),
              child: const Text('OK')),
        ]);
  }

  // OKボタン押下時のイベント処理
  // 選択された時間を設定ファイルに反映する
  // 2024/03/01 newTimeの分がたまに1分ずれる、リストの位置が微妙にずれることによる不具合なのか、実装が間違っているのか不明
  // 2024/03/02 おそらくループする時にindexがオーバーフローするのが原因なので補正処理を入れた
  void _onOkPressed(context, ref, hourCtrl, minCtrl, secCtrl) {
    // スクロールビューのLoop時にindexがオーバーフローするので要素数を元に補正数
    int h = hourCtrl.selectedItem % 24;
    int m = minCtrl.selectedItem % 60;
    int s = secCtrl.selectedItem % 60;
    final now = DateTime.now();
    final newTime = now.copyWith(
        hour: h,
        minute: m,
        second: s,
        millisecond: 0,
        microsecond: 0);
    // 現在時刻と設定時刻の差分を設定ファイルに反映
    ref.read(configProvider.notifier).systemTimeDiff =
        newTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    Navigator.of(context).pop();
  }
}
