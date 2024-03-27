import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_widget/application_timer.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// アプリケーション時刻を表示する
class DigitalClockWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationDateTime = ref.watch(applicationTimerProvider);
    final config = ref.watch(configProvider);

    String hh = applicationDateTime.hour.toString().padLeft(2, '0');
    String mm = applicationDateTime.minute.toString().padLeft(2, '0');
    String ss = applicationDateTime.second.toString().padLeft(2, '0');

    return Text('${hh}${config.hourMinSeparator}${mm}${config.minSecSeparator}${ss}');
  }
}
