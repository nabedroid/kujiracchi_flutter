import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  final int kujiraIconSize;
  final int systemTimeDiff;
  final int hourCharRatio;
  final String hourMinSeparator;
  final int hourMinSeparatorRatio;
  final int minCharRatio;
  final String minSecSeparator;
  final int minSecSeparatorRatio;
  final int secCharRatio;
  final String secDecimalSeparator;
  final int secDecimalSeparatorRatio;
  final int decimalCharRatio;
  final int timerDecimalDigits;
  final int stopwatchDecimalDigits;
  final int remainDecimalDigits;
  final int remainViewUpDownButtonsRatio;
  final int screenBrightness;

  const Config({
    this.kujiraIconSize = 64,
    this.systemTimeDiff = 0,
    this.hourCharRatio = 8,
    this.hourMinSeparator = ':',
    this.hourMinSeparatorRatio = 1,
    this.minCharRatio = 12,
    this.minSecSeparator = '\'',
    this.minSecSeparatorRatio = 1,
    this.secCharRatio = 12,
    this.secDecimalSeparator = '.',
    this.secDecimalSeparatorRatio = 1,
    this.decimalCharRatio = 4,
    this.timerDecimalDigits = 0,
    this.stopwatchDecimalDigits = 1,
    this.remainDecimalDigits = 0,
    this.remainViewUpDownButtonsRatio = 1,
    this.screenBrightness = 100,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      kujiraIconSize: json['kujiraIconSize'],
      systemTimeDiff: json['systemTimeDiff'],
      hourCharRatio: json['hourCharRatio'],
      hourMinSeparator: json['hourMinSeparator'],
      hourMinSeparatorRatio: json['hourMinSeparatorRatio'],
      minCharRatio: json['minCharRatio'],
      minSecSeparator: json['minSecSeparator'],
      minSecSeparatorRatio: json['minSecSeparatorRatio'],
      secCharRatio: json['secCharRatio'],
      secDecimalSeparator: json['secDecimalSeparator'],
      secDecimalSeparatorRatio: json['secDecimalSeparatorRatio'],
      decimalCharRatio: json['decimalCharRatio'],
      timerDecimalDigits: json['timerDecimalDigits'],
      stopwatchDecimalDigits: json['stopwatchDecimalDigits'],
      remainDecimalDigits: json['remainDecimalDigits'],
      remainViewUpDownButtonsRatio: json['remainViewUpDownButtonsRatio'],
      screenBrightness: json['screenBrightness'],
    );
  }
  
  factory Config.fromSharedPreferences(SharedPreferences sp) {
    Config config;
    final jsonString = sp.getString('config');
    if (jsonString == null) {
      // アプリを初めて起動した場合はデフォルトの値を使用する
      config = Config();
    } else {
      // 二度目以降は保存されているデータを使用する
      final json = jsonDecode(jsonString);
      config = Config.fromJson(json);
    }
    return config;
  }

  Config copyWith({
    int? kujiraIconSize,
    int? systemTimeDiff,
    int? hourCharRatio,
    String? hourMinSeparator,
    int? hourMinSeparatorRatio,
    int? minCharRatio,
    String? minSecSeparator,
    int? minSecSeparatorRatio,
    int? secCharRatio,
    String? secDecimalSeparator,
    int? secDecimalSeparatorRatio,
    int? decimalCharRatio,
    int? timerDecimalDigits,
    int? stopwatchDecimalDigits,
    int? remainDecimalDigits,
    int? remainViewUpDownButtonsRatio,
    int? screenBrightness,
  }) {
    return Config(
      kujiraIconSize: kujiraIconSize ?? this.kujiraIconSize,
      systemTimeDiff: systemTimeDiff ?? this.systemTimeDiff,
      hourCharRatio: hourCharRatio ?? this.hourCharRatio,
      hourMinSeparator: hourMinSeparator ?? this.hourMinSeparator,
      hourMinSeparatorRatio:
          hourMinSeparatorRatio ?? this.hourMinSeparatorRatio,
      minCharRatio: minCharRatio ?? this.minCharRatio,
      minSecSeparator: minSecSeparator ?? this.minSecSeparator,
      minSecSeparatorRatio: minSecSeparatorRatio ?? this.minSecSeparatorRatio,
      secCharRatio: secCharRatio ?? this.secCharRatio,
      secDecimalSeparator: secDecimalSeparator ?? this.secDecimalSeparator,
      secDecimalSeparatorRatio:
          secDecimalSeparatorRatio ?? this.secDecimalSeparatorRatio,
      decimalCharRatio: decimalCharRatio ?? this.decimalCharRatio,
      timerDecimalDigits: timerDecimalDigits ?? this.timerDecimalDigits,
      stopwatchDecimalDigits:
          stopwatchDecimalDigits ?? this.stopwatchDecimalDigits,
      remainDecimalDigits: remainDecimalDigits ?? this.remainDecimalDigits,
      remainViewUpDownButtonsRatio:
          remainViewUpDownButtonsRatio ?? this.remainViewUpDownButtonsRatio,
      screenBrightness: screenBrightness ?? this.screenBrightness,
    );
  }
}

class ConfigNotifier extends StateNotifier<Config> {
  ConfigNotifier() : super(Config());

  set kujiraIconSize(int kujiraIconSize) {
    state = state.copyWith(kujiraIconSize: kujiraIconSize);
  }

  set systemTimeDiff(int systemTimeDiff) {
    state = state.copyWith(systemTimeDiff: systemTimeDiff);
  }

  set hourCharRatio(int hourCharRatio) {
    state = state.copyWith(hourCharRatio: hourCharRatio);
  }

  set hourMinSeparator(String hourMinSeparator) {
    state = state.copyWith(hourMinSeparator: hourMinSeparator);
  }

  set hourMinSeparatorRatio(int hourMinSeparatorRatio) {
    state = state.copyWith(hourMinSeparatorRatio: hourMinSeparatorRatio);
  }

  set minCharRatio(int minCharRatio) {
    state = state.copyWith(minCharRatio: minCharRatio);
  }

  set minSecSeparator(String minSecSeparator) {
    state = state.copyWith(minSecSeparator: minSecSeparator);
  }

  set minSecSeparatorRatio(int minSecSeparatorRatio) {
    state = state.copyWith(minSecSeparatorRatio: minSecSeparatorRatio);
  }

  set secCharRatio(int secCharRatio) {
    state = state.copyWith(secCharRatio: secCharRatio);
  }

  set secDecimalSeparator(String secDecimalSeparator) {
    state = state.copyWith(secDecimalSeparator: secDecimalSeparator);
  }

  set secDecimalSeparatorRatio(int secDecimalSeparatorRatio) {
    state = state.copyWith(secDecimalSeparatorRatio: secDecimalSeparatorRatio);
  }

  set decimalCharRatio(int decimalCharRatio) {
    state = state.copyWith(decimalCharRatio: decimalCharRatio);
  }

  set timerDecimalDigits(int timerDecimalDigits) {
    state = state.copyWith(timerDecimalDigits: timerDecimalDigits);
  }

  set stopwatchDecimalDigits(int stopwatchDecimalDigits) {
    state = state.copyWith(stopwatchDecimalDigits: stopwatchDecimalDigits);
  }

  set remainDecimalDigits(int remainDecimalDigits) {
    state = state.copyWith(remainDecimalDigits: remainDecimalDigits);
  }

  set remainViewUpDownButtonsRatio(int remainViewUpDownButtonsRatio) {
    state = state.copyWith(
        remainViewUpDownButtonsRatio: remainViewUpDownButtonsRatio);
  }

  set screenBrightness(int screenBrightness) {
    state = state.copyWith(screenBrightness: screenBrightness);
  }
}

final configProvider = StateNotifierProvider<ConfigNotifier, Config>((ref) {
  return ConfigNotifier();
});
