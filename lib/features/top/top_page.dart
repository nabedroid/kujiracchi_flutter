import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_widget/application_time.dart';
import 'package:kujiracchi_dart/battery/simple_battery.dart';
import 'package:kujiracchi_dart/common_widget/digital_clock_widget.dart';
import 'package:kujiracchi_dart/common_widget/screen_brightness.dart';
import 'package:kujiracchi_dart/common_widget/setting_time_dialog.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

class TopPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final _ = ref.watch(screenBrightnessProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('トップ'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            // 画面左側のRemain、Stopwatch、Timer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左上のRemain
                Expanded(
                  child: _buildTopPageDefaultButton(
                    context: context,
                    onPressed: () => Navigator.of(context).pushNamed('/remain'),
                    icon: Icon(Icons.schedule),
                    label: 'Remain',
                  ),
                ),
                Expanded(
                  // 画面左下のStopwatch、Timer
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 画面左下のStopwatch
                      Expanded(
                        child: _buildTopPageDefaultButton(
                          context: context,
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/timer'),
                          icon: Icon(Icons.timer_outlined),
                          label: 'Stopwatch',
                        ),
                      ),
                      // 画面左下の右側のStopwatch
                      Expanded(
                        child: _buildTopPageDefaultButton(
                          context: context,
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/stopwatch'),
                          icon: Icon(Icons.hourglass_bottom_outlined),
                          label: 'Timer',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // 画面右側の時計、設定
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 画面右上の時計
                Expanded(
                  child: _buildTopPageDefaultButton(
                    context: context,
                    onPressed: () => _onTimePressed(context: context, ref: ref),
                    icon: DigitalClockWidget(),
                  ),
                ),
                Expanded(
                  // 画面右下の設定
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 設定
                      Expanded(
                        child: _buildTopPageDefaultButton(
                          context: context,
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/config'),
                          icon: Icon(Icons.settings_outlined),
                          label: 'Setting',
                        ),
                      ),
                      // バッテリー
                      Expanded(
                        child: _buildTopPageDefaultButton(
                          context: context,
                          onPressed: () {},
                          icon: BatteryWidget(),
                        ),
                      ),
                      // 終了
                      Expanded(
                        child: _buildTopPageDefaultButton(
                          context: context,
                          // TODO: SystemNavigator.popはAndroidでのみ動作する。もしWebやiOSで動かす場合は別途対応が必要。ただし、iOSはそもそもアプリケーションからの終了処理を認めていない。
                          onPressed: () => SystemNavigator.pop(),
                          icon: Icon(Icons.exit_to_app_outlined),
                          label: 'Exit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// トップ画面の各ボタンを作成するメソッド
  Widget _buildTopPageDefaultButton({
    required BuildContext context,
    required Widget icon,
    required void Function()? onPressed,
    String? label,
  }) {
    return OutlinedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      onPressed: onPressed,
      // routeName == null ? {} : Navigator.of(context).pushNamed(routeName),
      //mainAxisSize: MainAxisSize.max,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (label != null)
            Align(
              alignment: Alignment.bottomCenter,
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          FittedBox(child: icon),
        ],
      ),
    );
  }

  /// 画面右上の時間部分をクリックした際のイベント処理
  /// 時間設定ダイアログを表示し、アプリケーション時間を更新する
  void _onTimePressed({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    // 時間設定ダイアログを表示する
    final result = await showDialog(
        context: context,
        builder: (context) {
          final applicationDateTime = ref.read(applicationTimeProvider);
          // ダイアログの時分秒の初期値はアプリケーション時間を使用
          return SettingTimeDialog(
            // TODO: デフォルト値を0:0:0にしているので、後で戻すこと
            // hour: applicationDateTime.hour,
            // min: applicationDateTime.minute,
            // sec: applicationDateTime.second,
          );
        });
    // ダイアログでOKが押下された場合はアプリケーション時間を更新
    if (result != null) {
      final now = DateTime.now();
      final newTime = now.copyWith(
          hour: result.hour,
          minute: result.min,
          second: result.sec,
          // ミリ秒以下はダイアログで設定出来ないので0にしておく
          millisecond: 0,
          microsecond: 0);
      // 現在時刻と設定時刻の差分を設定ファイルに反映
      ref.read(configProvider.notifier).systemTimeDiff =
          newTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    }
  }
}
