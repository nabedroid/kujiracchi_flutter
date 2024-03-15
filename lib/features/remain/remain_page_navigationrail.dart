import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kujiracchi_dart/features/remain/remain_page_remove_schedule_dialog.dart';
import 'package:kujiracchi_dart/features/remain/remain_page_state.dart';
import 'package:kujiracchi_dart/features/schedule/schedule.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_list_provider.dart';

// 拡張状態フラグ
final _navigationRailExtendedProvider =
    StateProvider.autoDispose<bool>((ref) => false);
// 編集状態のスケジュールのID（null：編集状態のスケジュールが存在しない（初期状態等））
final _editScheduleIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);
// テキストフィールドのフォーカス
final _focusNodeProvider =
    StateProvider.autoDispose<FocusNode>((ref) => FocusNode());

class RemainPageNavigationRail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editScheduleId = ref.watch(_editScheduleIdProvider);
    final scheduleList = ref.watch(scheduleListProvider);
    final extended = ref.watch(_navigationRailExtendedProvider);
    final remainPageState = ref.watch(remainPageStateProvider);
    final itemFocusNode = ref.watch(_focusNodeProvider);

    final controller = TextEditingController();

    return GestureDetector(
      // 編集状態を解除する
      onTap: () {
        itemFocusNode.requestFocus();
        _toggleEditScheduleName(ref: ref);
      },
      // 画面左のスケジュール管理するメニュー
      child: NavigationRail(
        // 縮小表示の幅
        minWidth: 50,
        // 拡張表示の幅
        minExtendedWidth: 400,
        // 拡張要否
        extended: extended,
        // 縮小状態でラベルを表示する方法（拡張時にnoneにしてないとエラー）
        labelType: NavigationRailLabelType.none,
        // メニュークリックのイベント処理
        onDestinationSelected: (index) => _onDestinationSelected(
          index: index,
          ref: ref,
          extended: extended,
          scheduleList: scheduleList,
        ),
        // 本当はleadingとtrailingに開閉と追加を実装したかったけど、
        // destinationsに2つ以上要素がないと例外が発生するので仕方なくここに実装
        destinations: [
          // navigationRail開閉ボタン
          NavigationRailDestination(
              icon: Icon(extended ? Icons.menu_open : Icons.menu_outlined),
              label: Text('メニューを閉じる')),
          // スケジュール一覧
          for (int i = 0; i < scheduleList.schedules.length; i++)
            _buildNavigationRailDestination(
              index: i,
              editScheduleId: editScheduleId,
              schedule: scheduleList.schedules.elementAt(i),
              scheduleList: scheduleList,
              ref: ref,
              context: context,
              remainPageState: remainPageState,
            ),
          // スケジュール追加ボタン
          NavigationRailDestination(
            icon: Icon(Icons.add),
            label: Text('スケジュール追加'),
          ),
        ],
        trailing: Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Icon(Icons.abc),
          ),
        ),
        selectedIndex: null,
      ),
    );
  }

  /// スケジュールに応じたNavigationRailDestinationを生成する
  NavigationRailDestination _buildNavigationRailDestination({
    required int index,
    String? editScheduleId,
    required Schedule schedule,
    required WidgetRef ref,
    required ScheduleList scheduleList,
    required BuildContext context,
    required RemainPageState remainPageState,
  }) {
    // テキストフィールドの値を操作するコントローラー
    final controller = TextEditingController();
    return NavigationRailDestination(
      // スケジュール名の一文字目をアイコンとして使用する
      // スケジュール名が空の場合は"塩"と表示
      icon: Text(schedule.name.trim().isEmpty
          ? '塩'
          : schedule.name.trim().substring(0, 1)),
      // スケジュール名部分にフォーカスイベントを追加する
      label: Focus(
        // テキストフィールドからフォーカスアウトしたらスケジュール名を保存する
        // テキストフィールドにフォーカスインしたらスケジュール名を初期値に設定する
        onFocusChange: (focused) {
          print('focus change ${focused}');
          if (focused) {
            // テキストフィールドにフォーカスイン
            controller.text = schedule.name;
          } else {
            // テキストフィールドからフォーカスアウト
            ref.read(scheduleListProvider.notifier).updateSchedule(
                  schedule.id,
                  name: controller.text,
                );
            _toggleEditScheduleName(ref: ref);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // スケジュール名部分のwidget
            GestureDetector(
              // 空白領域のイベントも検知する
              behavior: HitTestBehavior.translucent,
              // タイトルをtapで編集状態を解除する
              onTap: () {
                _toggleEditScheduleName(ref: ref);
              },
              // タイトルを長押しで編集状態にする
              onLongPress: () {
                _toggleEditScheduleName(ref: ref, scheduleId: schedule.id);
              },
              // 編集状態ならテキストフィールドを、それ以外はテキストで表示
              child: SizedBox(
                width: 200,
                height: 40,
                // 編集状態か判定
                child: schedule.id == editScheduleId
                    ? TextField(
                        controller: controller,
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          schedule.name,
                          textAlign: TextAlign.left,
                        )),
              ),
            ),
            // 並び順（上）ボタン
            IconButton(
              icon: Icon(Icons.keyboard_arrow_up_outlined),
              onPressed: () => _reorderScheduleUp(index, ref),
            ),
            // 並び順（下）ボタン
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down_outlined),
              onPressed: () => _reorderScheduleDown(index, scheduleList, ref),
            ),
            // ゴミ箱ボタン
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _removeSchedule(
                  schedule: schedule,
                  context: context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 削除ダイアログを表示する
  void _removeSchedule({
    required Schedule schedule,
    required BuildContext context,
  }) {
    // ダイアログで選択状態のスケジュールを使用するため、スケジュールを選択状態にする
    showDialog(
      context: context,
      builder: (context) =>
          RemainPageRemoveScheduleDialog(scheduleId: schedule.id),
    );
  }

  /// スケジュールの並び順を上に移動する
  void _reorderScheduleUp(final int index, final ref) {
    if (index > 0) {
      ref.read(scheduleListProvider.notifier).reorderSchedule(index, index - 1);
    }
  }

  /// スケジュールの並び順を下に移動する
  void _reorderScheduleDown(final int index, final scheduleList, final ref) {
    if (index < scheduleList.schedules.length - 1) {
      ref.read(scheduleListProvider.notifier).reorderSchedule(index, index + 2);
    }
  }

  /// メニューの開閉、スケジュール、スケジュール追加の何れかが押下された時の処理
  void _onDestinationSelected({
    required int index,
    required scheduleList,
    required ref,
    required extended,
  }) {
    // メニューの先頭は開閉ボタン、末尾は追加ボタンなのでindexで場合分け
    final schedulesCount = scheduleList.schedules.length;
    if (index == 0) {
      // メニュー開閉ボタン
      _toggleExtended(isExtended: !extended, ref: ref);
    } else if (index <= schedulesCount) {
      // スケジュールを選択
      _selectSchedule(
          schedule: scheduleList.schedules.elementAt(index - 1),
          scheduleList: scheduleList,
          ref: ref);
    } else if (index == schedulesCount + 1) {
      // スケジュール追加
      _addSchedule(ref: ref);
    }
  }

  /// スケジュールを選択状態にする
  void _selectSchedule({
    required Schedule schedule,
    required ScheduleList scheduleList,
    required WidgetRef ref,
  }) {
    ref.read(remainPageStateProvider.notifier).selectedScheduleId = schedule.id;
  }

  /// メニューの開閉を切り替える
  void _toggleExtended({required bool isExtended, required WidgetRef ref}) {
    ref.read(_editScheduleIdProvider.notifier).state = null;
    ref.read(_navigationRailExtendedProvider.notifier).state = isExtended;
  }

  /// 名前を編集するスケジュールを切り替える
  /// スケジュールIDがnullの場合は編集状態を解除
  void _toggleEditScheduleName({required ref, String? scheduleId}) {
    ref.read(_editScheduleIdProvider.notifier).state = scheduleId;
  }

  /// スケジュールを追加する
  void _addSchedule({required WidgetRef ref}) {
    ref.read(scheduleListProvider.notifier).addSchedule(
          Schedule(name: '新しいスケジュール${DateTime.now().millisecond}'),
        );
  }
}
