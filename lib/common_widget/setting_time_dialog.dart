import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/application_time.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// 時間選択に使用するScrollViewライクなウィジェット
class _SettingTimeDialogListView extends ConsumerWidget {
  final List<int> items;
  final Size timeWidgetSize;
  final FixedExtentScrollController controller;
  final double fontSize;

  _SettingTimeDialogListView({
    required this.items,
    required this.timeWidgetSize,
    required this.controller,
    required this.fontSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: timeWidgetSize.width,
      height: timeWidgetSize.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        // 拡大鏡
        useMagnifier: true,
        magnification: 1.3,
        // 前後間隔の倍率？（1未満：広い、1以上：狭い）
        squeeze: 0.9,
        physics: FixedExtentScrollPhysics(),
        itemExtent: fontSize * 1.2,
        childDelegate: ListWheelChildLoopingListDelegate(
            children: items
                .map((item) => Center(
                    child: Text(item.toString(),
                        style: TextStyle(fontSize: fontSize))))
                .toList()),
      ),
    );
  }
}

/// 時間設定を行うダイアログ
/// 戻り値はRecord(int hour, int min, int sec)?（キャンセルボタンが押下された場合はnull）となる。
class SettingTimeDialog extends ConsumerWidget {
  final int hour;
  final int min;
  final int sec;

  SettingTimeDialog({
    Key? key,
    this.hour = 0,
    this.min = 0,
    this.sec = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = Theme.of(context).textTheme.titleLarge!.fontSize!;
    // リストビューの上下数字の表示範囲を含めたサイズ
    final timeWidgetSize = Size(fontSize * 2, fontSize * 5);
    // リストビューのアイテムが中途半端な位置で止まらない設定
    late final hourCtrl = FixedExtentScrollController(initialItem: hour);
    late final minCtrl = FixedExtentScrollController(initialItem: min);
    late final secCtrl = FixedExtentScrollController(initialItem: sec);

    return AlertDialog(
        title: const Text('時間設定'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SettingTimeDialogListView(
              items: List<int>.generate(24, (i) => i),
              timeWidgetSize: timeWidgetSize,
              controller: hourCtrl,
              fontSize: fontSize,
            ),
            Text(' : ',
                style: TextStyle(
                    fontSize: fontSize * 1.5, fontWeight: FontWeight.bold)),
            _SettingTimeDialogListView(
              items: List<int>.generate(60, (i) => i),
              timeWidgetSize: timeWidgetSize,
              controller: minCtrl,
              fontSize: fontSize,
            ),
            Text(' : ',
                style: TextStyle(
                    fontSize: fontSize * 1.5, fontWeight: FontWeight.bold)),
            _SettingTimeDialogListView(
              items: List<int>.generate(60, (i) => i),
              timeWidgetSize: timeWidgetSize,
              controller: secCtrl,
              fontSize: fontSize,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _onCancelPressed(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => _onOkPressed(
              context: context,
              ref: ref,
              hourCtrl: hourCtrl,
              minCtrl: minCtrl,
              secCtrl: secCtrl,
            ),
            child: const Text('OK'),
          ),
        ]);
  }

  /// キャンセルボタン押下時の処理
  /// 特に何もせずにダイアログを閉じる
  void _onCancelPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// OKボタン押下時の処理
  /// 入力された時、分、秒を返り値に設定してダイアログを閉じる
  void _onOkPressed({
    required BuildContext context,
    required WidgetRef ref,
    required FixedExtentScrollController hourCtrl,
    required FixedExtentScrollController minCtrl,
    required FixedExtentScrollController secCtrl,
  }) {
    Navigator.of(context).pop<({int hour, int min, int sec})>((
      hour: hourCtrl.selectedItem % 24,
      min: minCtrl.selectedItem % 60,
      sec: secCtrl.selectedItem % 60,
    ));
  }
}
