import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screen_brightness/screen_brightness.dart';

import 'package:kujiracchi_dart/common_utils/string_util.dart';
import 'package:kujiracchi_dart/common_widget/custom_slider_widget.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// 設定ページ
class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState createState() => _ConfigPageState();
}

/// 設定ページの表示方法
enum _ConfigPageMode {
  normal,
  advanced,
}

/// 設定ページの表示方法を制御するProvider
final _configPageStateProvider =
    StateProvider<_ConfigPageMode>((ref) => _ConfigPageMode.normal);

class _ConfigPageState extends ConsumerState<ConfigPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //_config = ref.read(configProvider);
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(_configPageStateProvider);
    final config = ref.watch(configProvider);
    final trailingWidth = MediaQuery.of(context).size.width * 0.2;

    return PopScope(
      onPopInvoked: (didPop) {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('設定'),
        ),
        body: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text('システム時間差'),
                subtitle: Text('アプリ内の時間とシステム時間とのズレ（ミリ秒）'),
                trailing: SizedBox(
                  width: trailingWidth,
                  child: TextFormField(
                    initialValue: config.systemTimeDiff.toString(),
                    onSaved: (value) {
                      final intValue = int.parse(value!);
                      if (config.systemTimeDiff != intValue) {
                        ref.read(configProvider.notifier).systemTimeDiff =
                            intValue;
                      }
                    },
                    maxLength: 9,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (StringUtil.isInt(value) == false) {
                        return '数値を入力してください';
                      }
                      return null;
                    },
                    onTapOutside: (e) => primaryFocus?.unfocus(),
                  ),
                ),
              ),
              _buildCharRatioListTile(
                title: 'くじらアイコンのサイズ',
                trailingWidth: trailingWidth,
                value: config.kujiraIconSize,
                min: 32,
                max: 256,
                divisions: 7,
                onChanged: (value) =>
                ref.read(configProvider.notifier).kujiraIconSize = value,
              ),
              _buildCharRatioListTile(
                title: 'スクリーン輝度',
                trailingWidth: trailingWidth,
                value: config.screenBrightness,
                min: 1,
                max: 100,
                divisions: 100,
                onChanged: (value) =>
                ref.read(configProvider.notifier).screenBrightness = value,
              ),
              // メニュー長押しで詳細設定モードにする
              if (mode == _ConfigPageMode.normal)
                ListTile(
                  title: const Text('詳細設定を開く'),
                  onLongPress: () {
                    ref.read(_configPageStateProvider.notifier).state =
                        _ConfigPageMode.advanced;
                  },
                ),
              // 詳細設定モードの場合に時刻関連の設定を表示する
              if (mode == _ConfigPageMode.advanced)
                ...[
                ListTile(
                  title: const Text('時刻表示設定'),
                ),
                ListTile(
                  title: const Text('文字サイズの比率'),
                  subtitle: const Text('時刻（HH:MM\'SS.FFF）の文字サイズ比率をカスタマイズします。'),
                ),
                _buildCharRatioListTile(
                  title: '時（HH）の文字比率',
                  trailingWidth: trailingWidth,
                  value: config.hourCharRatio,
                  onChanged: (value) =>
                      ref.read(configProvider.notifier).hourCharRatio = value,
                ),
                _buildCharRatioListTile(
                  title: '時間と分の区切り文字（:）比率',
                  trailingWidth: trailingWidth,
                  value: config.hourMinSeparatorRatio,
                  onChanged: (value) => ref
                      .read(configProvider.notifier)
                      .hourMinSeparatorRatio = value,
                ),
                _buildCharRatioListTile(
                  title: '分（MM）の文字の比率',
                  trailingWidth: trailingWidth,
                  value: config.minCharRatio,
                  onChanged: (value) =>
                      ref.read(configProvider.notifier).minCharRatio = value,
                ),
                _buildCharRatioListTile(
                  title: '分と秒の区切り文字（\'）の比率',
                  trailingWidth: trailingWidth,
                  value: config.minSecSeparatorRatio,
                  onChanged: (value) => ref
                      .read(configProvider.notifier)
                      .minSecSeparatorRatio = value,
                ),
                _buildCharRatioListTile(
                  title: '秒（SS）の文字比率',
                  trailingWidth: trailingWidth,
                  value: config.secCharRatio,
                  onChanged: (value) =>
                      ref.read(configProvider.notifier).secCharRatio = value,
                ),
                _buildCharRatioListTile(
                  title: '秒とミリ秒の区切り文字（.）比率',
                  trailingWidth: trailingWidth,
                  value: config.secDecimalSeparatorRatio,
                  onChanged: (value) => ref
                      .read(configProvider.notifier)
                      .secDecimalSeparatorRatio = value,
                ),
                _buildCharRatioListTile(
                  title: 'ミリ秒（FFF）の文字比率',
                  trailingWidth: trailingWidth,
                  value: config.decimalCharRatio,
                  onChanged: (value) =>
                      ref.read(configProvider.notifier).decimalCharRatio = value,
                ),
                ListTile(
                  title: const Text('項目ごとの区切り文字'),
                  subtitle: const Text('時、分、秒、ミリ秒の区切り文字をカスタマイズします。'),
                ),
                _buildSeparatorCharListTile(
                  title: '時と分の区切り文字',
                  trailingWidth: trailingWidth,
                  initialValue: config.hourMinSeparator,
                  onSaved: (value) =>
                      ref.read(configProvider.notifier).hourMinSeparator = value,
                ),
                _buildSeparatorCharListTile(
                  title: '分と秒の区切り文字',
                  trailingWidth: trailingWidth,
                  initialValue: config.minSecSeparator,
                  onSaved: (value) =>
                      ref.read(configProvider.notifier).minSecSeparator = value,
                ),
                _buildSeparatorCharListTile(
                  title: '秒とミリ秒の区切り文字',
                  trailingWidth: trailingWidth,
                  initialValue: config.secDecimalSeparator,
                  onSaved: (value) => ref
                      .read(configProvider.notifier)
                      .secDecimalSeparator = value,
                ),
                ListTile(
                  title: const Text('機能ごとのミリ秒の有効桁数'),
                ),
                _buildCharRatioListTile(
                  title: 'タイマーのミリ秒の桁数',
                  trailingWidth: trailingWidth,
                  value: config.timerDecimalDigits,
                  max: 3,
                  onChanged: (value) => ref
                      .read(configProvider.notifier)
                      .timerDecimalDigits = value,
                ),
                _buildCharRatioListTile(
                  title: 'ストップウォッチのミリ秒の桁数',
                  trailingWidth: trailingWidth,
                  value: config.stopwatchDecimalDigits,
                  max: 3,
                  onChanged: (value) => ref
                      .read(configProvider.notifier)
                      .stopwatchDecimalDigits = value,
                ),
                _buildCharRatioListTile(
                  title: 'リメインのミリ秒の桁数',
                  trailingWidth: trailingWidth,
                  value: config.remainDecimalDigits,
                  max: 3,
                  onChanged: (value) => ref
                      .read(configProvider.notifier)
                      .remainDecimalDigits = value,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 文字比率をスライダーで操作する項目を生成
  ListTile _buildCharRatioListTile({
    required String title,
    required double trailingWidth,
    required int value,
    required Function(int) onChanged,
    int min = 0,
    int max = 20,
    int? divisions,
  }) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: trailingWidth,
        child: SliderWrapper(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions ?? max - min,
            label: value.toString(),
            onChanged: (double value) {
              onChanged(value.toInt());
            },
          ),
        ),
      ),
    );
  }

  /// 区切り文字の項目を生成
  ListTile _buildSeparatorCharListTile({
    required String title,
    required double trailingWidth,
    required String initialValue,
    required Function(String) onSaved,
  }) {
    return ListTile(
      title: Text(title),
      trailing: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          overlayShape: SliderComponentShape.noThumb,
        ),
        child: Container(
          padding: EdgeInsets.all(0.0),
          width: trailingWidth,
          child: TextFormField(
            onSaved: (value) {
              if (value != null && value.length == 1) {
                onSaved(value);
              }
            },
            initialValue: initialValue,
            maxLength: 1,
            validator: (value) {
              if (value?.length != 1) {
                return '1文字入力してください';
              }
              return null;
            },
            onTapOutside: (e) => primaryFocus?.unfocus(),
          ),
        ),
      ),
    );
  }
}
