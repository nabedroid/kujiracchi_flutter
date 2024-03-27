import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/config/config.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// コンフィグのスクリーン輝度を監視してアプリの輝度を変更する
/// アプリの初期画面で呼び出して使用する
final screenBrightnessProvider =
    StateProvider.autoDispose<void>((ref) {
      final screenBrightness = ref.watch(configProvider.select((config) => config.screenBrightness));
      ScreenBrightness().setScreenBrightness(screenBrightness / 100);
    });
