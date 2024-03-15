import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// （ミリ）秒数をhh:mm:ss形式で表示する
/// 時、分が0の場合は該当箇所を表示せずに該当箇所以外を広げる
/// 秒数がマイナスの場合は赤字とする
/// カウントダウンの場合は小数点を切り上げて表示する
/// 0.5秒 -> 1秒
/// 0秒 -> 0秒
/// -0.5秒 -> 0秒
///
class CountDisplayWidget extends ConsumerWidget {
  final int decimalDigits;
  final bool isCountUp;
  final bool isMilliseconds;
  final int count;

  CountDisplayWidget({
    Key? key,
    required this.count,
    this.isCountUp = true,
    this.isMilliseconds = true,
    this.decimalDigits = 0,
  }) : super(key: key) {
    if ((0 <= decimalDigits && decimalDigits <= 3) == false) {
      throw ArgumentError(
          'your decimal digits is ${decimalDigits}, but only 0-3 can be used.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    // 必要ならミリ秒に変換
    int ms = (isMilliseconds ? count : count * 1000).abs();
    // カウントアップは小数点を切り上げて、カウントダウンの場合は小数点を切り上げて表示
    // 移行の処理を全て切り下げ前提で計算するので整数部に+1して帳尻を合わせる
    final significantDigits =
        decimalDigits == 3 ? 0 : pow(10, 3 - decimalDigits).floor();
    // 小数部分が0の場合は何もしない
    if (ms % significantDigits != 0) {
      if (isCountUp) {
        if (count < 0) {
          // カウントアップかつ負の時間は切り上げ補正
          ms = ms + significantDigits;
        } else {
          // 何もしない
        }
      } else {
        if (count < 0) {
          // 何もしない
        } else {
          // カウントダウンかつ正の時間は切り上げ補正
          ms = ms + significantDigits;
        }
      }
    }
    //print('${count} ${ms}');
    // hour、min、sec、decimalをそれぞれ計算
    final h = (ms / 1000 / 3600).floor();
    final m = (ms / 1000 / 60).floor() % 60;
    final s = (ms / 1000).floor() % 60;
    final f = ms % 1000;
    // 0埋め
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    final ff = f.toString().padLeft(3, '0').substring(0, decimalDigits);
    // widget作成
    return DefaultTextStyle.merge(
      style: count >= 0
          ? TextStyle()
          : TextStyle(color: Theme.of(context).colorScheme.error),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // hour
          if (h > 0) Expanded(flex: config.hourCharRatio, child: FittedBox(child: Text(hh))),
          if (h > 0) Expanded(flex: config.hourMinSeparatorRatio, child: FittedBox(child: Text(config.hourMinSeparator))),
          // min
          if (h > 0 || m > 0)
            Expanded(flex: config.minCharRatio, child: FittedBox(child: Text(mm))),
          if (h > 0 || m > 0)
            Expanded(flex: config.minSecSeparatorRatio, child: FittedBox(child: Text(config.minSecSeparator))),
          // sec
          Expanded(flex: config.secCharRatio, child: FittedBox(child: Text(ss))),
          // decimal
          if (decimalDigits > 0)
            Expanded(flex: config.secDecimalSeparatorRatio, child: FittedBox(child: Text(config.secDecimalSeparator))),
          if (decimalDigits > 0)
            Expanded(flex: config.decimalCharRatio, child: FittedBox(child: Text(ff))),
        ],
      ),
    );
  }
}
