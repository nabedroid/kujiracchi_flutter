import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/common_widget/count_display_widget.dart';
import 'package:kujiracchi_dart/common_widget/setting_time_dialog.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

enum _TimerState {
  running,
  stop,
}

final _timerPageStateProvider =
    StateProvider.autoDispose<_TimerState>((ref) => _TimerState.stop);

final _timerPageSettingTimeProvider = StateProvider.autoDispose<int>((ref) => 0);

final _timerCountProvider = StateNotifierProvider.autoDispose<TimerNotifier, int>((ref) {
  return TimerNotifier(50, false);
});

class TimerPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final settingTime = ref.watch(_timerPageSettingTimeProvider);
    final count = ref.watch(_timerCountProvider);
    final state = ref.watch(_timerPageStateProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Timer'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: GestureDetector(
              onTap: () => _onSettingTimePressed(
                context: context,
                state: state,
                ref: ref,
              ),
              child: CountDisplayWidget(
                isCountUp: false,
                decimalDigits: config.timerDecimalDigits,
                count: settingTime - count,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 再生、停止ボタン
                  state == _TimerState.stop
                      ? _buildStopwatchControlButtons(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () => _onPlayPressed(state: state, ref: ref),
                        )
                      : _buildStopwatchControlButtons(
                          icon: Icon(Icons.stop),
                          onPressed: () => _onStopPressed(state: state, ref: ref),
                        ),
                  _buildStopwatchControlButtons(
                    icon: Icon(Icons.restart_alt),
                    onPressed: () => _onResetPressed(state: state, ref: ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopwatchControlButtons({
    required Widget icon,
    required void Function() onPressed,
  }) {
    return FittedBox(
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }

  void _onPlayPressed({required _TimerState state, required WidgetRef ref}) {
    if (state == _TimerState.stop) {
      ref.read(_timerCountProvider.notifier).start();
      ref
          .read(_timerPageStateProvider.notifier)
          .state = _TimerState.running;
    }
  }

  void _onStopPressed({required _TimerState state, required WidgetRef ref}) {
    if (state == _TimerState.running) {
      ref.read(_timerCountProvider.notifier).stop();
      ref
          .read(_timerPageStateProvider.notifier)
          .state = _TimerState.stop;
    }
  }

  void _onResetPressed({required _TimerState state, required WidgetRef ref}) {
    if (state == _TimerState.stop) {
      ref.read(_timerCountProvider.notifier).reset();
    }
  }

  void _onSettingTimePressed({
    required BuildContext context,
    required _TimerState state,
    required WidgetRef ref,
  }) async {
    if (state == _TimerState.stop) {
      // 停止状態の場合のみダイアログを開く
      final result = await showDialog(
        context: context,
        builder: (context) {
          return SettingTimeDialog();
        },
      );
      if (result != null) {
        // タイマー初期化
        ref.read(_timerCountProvider.notifier).reset();
        // 時間設定
        ref.read(_timerPageSettingTimeProvider.notifier).state = (result.hour * 3600 + result.min  * 60 + result.sec) * 1000;
      }
    }
  }
}
