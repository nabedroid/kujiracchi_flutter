import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:battery_plus/battery_plus.dart';

/// バッテリーの残数、充電状況
class SimpleBattery {
  /// バッテリーの充電状況
  final BatteryState state;

  /// バッテリーの残数（%）
  final int level;

  /// デフォルト値は充電状況：不明、残数：-1
  const SimpleBattery({this.state = BatteryState.unknown, this.level = -1});

  SimpleBattery copyWith({
    BatteryState? state,
    int? level,
  }) {
    return SimpleBattery(
        state: state ?? this.state, level: level ?? this.level);
  }

  @override
  String toString() {
    return 'state: ${state}, level: ${level}';
  }
}

/// バッテリー状態を管理する
/// battery_plus/BatteryをRiverpodで使いやすくしている
class SimpleBatteryNotifier extends StateNotifier<SimpleBattery> {
  /// バッテリーの残数確認で使用するタイマー
  Timer? _timer;
  /// バッテリー残数の監視頻度
  Duration _updateDuration = Duration(seconds: 1);
  /// バッテリーの状態を取得するパッケージ
  final Battery _battery = Battery();

  /// バッテリーの充電状況を監視をコントロール（dispose時にキャンセルするために使用）
  StreamSubscription<BatteryState>? _streamSubscription;

  SimpleBatteryNotifier() : super(SimpleBattery()) {
    /// バッテリーの充電状況（充電中、非充電中等）を監視
    _streamSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState batteryState) {
      _update(batteryState: batteryState);
    });

    /// バッテリーの残数確認を開始
    _run();
  }

  set updateDuration(Duration duration) => _updateDuration = duration;

  /// バッテリーの残数を1秒ごとに確認する
  void _run() async {
    int batteryLevel = await _battery.batteryLevel;
    // バッテリー残数に変化がある場合のみ更新
    if (state.level != batteryLevel) {
      _update(batteryLevel: batteryLevel);
    }
    _timer?.cancel();
    _timer = Timer(_updateDuration, _run);
  }

  /// バッテリーの状態を更新する
  void _update({BatteryState? batteryState, int? batteryLevel}) async {
    state = state.copyWith(state: batteryState, level: batteryLevel);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }
}

/// バッテリーの状況を公開する
final batteryProvider =
    StateNotifierProvider.autoDispose<SimpleBatteryNotifier, SimpleBattery>((ref) {
  return SimpleBatteryNotifier();
});

/// バッテリーの状態を表示する
class BatteryWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryProvider);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        _getBatteryIcon(batteryState),
      ],
    );
  }

  Widget _getBatteryIcon(SimpleBattery batteryState) {
    Icon icon;
    if (batteryState.state == BatteryState.charging) {
      icon = Icon(Icons.battery_charging_full_outlined);
    } else if (batteryState.state == BatteryState.discharging) {
      switch (batteryState.level ~/ 12.5) {
        case 0:
          icon = Icon(Icons.battery_0_bar_outlined);
        case 1:
          icon = Icon(Icons.battery_1_bar_outlined);
        case 2:
          icon = Icon(Icons.battery_2_bar_outlined);
        case 3:
          icon = Icon(Icons.battery_3_bar_outlined);
        case 4:
          icon = Icon(Icons.battery_4_bar_outlined);
        case 5:
          icon = Icon(Icons.battery_5_bar_outlined);
        case 6:
          icon = Icon(Icons.battery_6_bar_outlined);
        case 7:
          icon = Icon(Icons.battery_full_outlined);
        case 8:
          icon = Icon(Icons.battery_full_outlined);
        default:
          icon = Icon(Icons.battery_unknown_outlined);
      }
    } else if (batteryState.state == BatteryState.full) {
      // バッテリーフルかつ充電中の場合、どのステータスになっているのか不明
      icon = Icon(Icons.battery_charging_full_outlined);
    } else {
      // バッテリー不明、接続状態（非充電状態）は？を表示
      icon = Icon(Icons.battery_unknown_outlined);
    }
    return icon;
  }
}
