import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

/// スライド可能なくじらウィジェット
class KujiraWidget extends ConsumerStatefulWidget {
  /// スライド完了時のコールバック
  final void Function() onSlided;

  const KujiraWidget({super.key, required this.onSlided});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _KujiraWidgetState();
  }
}

class _KujiraWidgetState extends ConsumerState<KujiraWidget>
    with SingleTickerProviderStateMixin {
  // アニメーションの進行状況
  late final AnimationController _controller;

  // アニメーションの開始・終了値
  late final Animation<Offset> _offsetAnimation;

  // くじらアイコン
  late Widget _kujiraIcon;

  @override
  void initState() {
    super.initState();
    //_kujiraIcon = ImageIcon(AssetImage('assets/kujira.png'), size: 128);
    _controller = AnimationController(vsync: this);
    _offsetAnimation = Tween(
      // 開始地点はウィジェット初期位置
      begin: Offset.zero,
      // 終了地点はウィジェット0.5分下
      end: Offset(0, 0.5),
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    // 設定ファイルからアイコンサイズを読み込み
    final iconSize = ref.watch(configProvider).kujiraIconSize;
    //_kujiraIcon = ImageIcon(AssetImage('assets/kujira.png'), size: iconSize.toDouble(), color: null);
    _kujiraIcon = Image(
        image: AssetImage('assets/kujira.png'),
        width: iconSize.toDouble(),
        height: iconSize.toDouble(),
        color: null);

    return GestureDetector(
      // アイコンが上下にドラッグされたらoffsetを変更
      onVerticalDragUpdate: (details) {
        double primaryDelta = details.primaryDelta ?? 0;
        if (primaryDelta < 0) {
          // 上方向にドラッグ
          _controller.value -= 0.01;
        } else if (primaryDelta > 0) {
          // 下方向にドラッグ
          _controller.value += 0.01;
        }
      },
      // ドラッグが終了したらコールバックを実行し、元の位置に戻す
      onVerticalDragEnd: (details) {
        if (_controller.value >= 1.0) {
          // offsetの上限まで移動していたらコールバックを実行
          widget.onSlided();
        }
        _controller.value = 0;
      },
      child: Align(
        child: SlideTransition(
          position: _offsetAnimation,
          child: _kujiraIcon,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}