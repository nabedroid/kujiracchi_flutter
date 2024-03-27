import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/common_widget/count_display_widget.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// ストップウォッチの状態
enum _StopwatchState {
  /// 稼働中
  running,
  /// 停止中
  stop,
}

/// ストップウォッチのカウント数を公開する
final _stopwatchTimerProvider =
    StateNotifierProvider.autoDispose<TimerNotifier, int>(
        (ref) => TimerNotifier(50, false));

/// ストップウォッチの状態を公開する
final _stopwatchStateProvider = StateProvider.autoDispose<_StopwatchState>((ref) => _StopwatchState.stop);

/// シンプルなストップウォッチ
/// 時、分はカウント数が規定値（60分、60秒）になるまで表示しない
/// ミリ秒以下の表示桁数は設定ファイルから取得する
class StopwatchWidget extends ConsumerWidget {
  const StopwatchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final state = ref.watch(_stopwatchStateProvider);
    final timer = ref.watch(_stopwatchTimerProvider);

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: CountDisplayWidget(
            decimalDigits: config.stopwatchDecimalDigits,
            count: timer,
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
                state == _StopwatchState.stop ?
                _buildStopwatchControlButtons(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () => _onPlayPressed(ref: ref),
                ) :
                  _buildStopwatchControlButtons(
                  icon: Icon(Icons.stop),
                  onPressed: () => _onStopPressed(ref: ref),
                ),
                _buildStopwatchControlButtons(
                  icon: Icon(Icons.restart_alt),
                  onPressed: () => _onResetPressed(ref: ref),
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _onPlayPressed({required WidgetRef ref}) {
    ref.read(_stopwatchTimerProvider.notifier).start();
    ref.read(_stopwatchStateProvider.notifier).state = _StopwatchState.running;
  }

  void _onStopPressed({required WidgetRef ref}) {
    ref.read(_stopwatchTimerProvider.notifier).stop();
    ref.read(_stopwatchStateProvider.notifier).state = _StopwatchState.stop;
  }

  void _onResetPressed({required WidgetRef ref}) {
    ref.read(_stopwatchTimerProvider.notifier).reset();
  }
}
