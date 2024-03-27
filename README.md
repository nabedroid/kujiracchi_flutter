# kujiracchi_dart

クジラッチのDartバージョン

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## やる事

- 全体
  - ~~画面右上の戻るボタンをくじらを引っ張って戻る方式にする~~
    - 実装したけど設定で普通のボタンも選択できるようにしたい
  - ボタンを押した際にアイコン部分だけエフェクト（Ink）出したい
    - 現状ボタン判定領域一杯にエフェクトが出て違和感を感じる
  - スケジュール、設定の保存先をSharedPreferences以外に変えたい
    - SPだとアプリやブラウザのアップデートやキャッシュクリアで消えそう
    - Driftとか良いらしい
    - 旧バージョンだとSDカードで管理してるらしいが・・・本当か・・・？
  - スマホで見ると、Timer、Stopwatch画面の再生、リセットボタンが小さい
  - スマホで見ると、トップ画面のアイコンと下の文字が重なる
    - 縦画面だとアイコンすら見えない
  - 横画面で固定できるようにする
  - 画面上部のステータスバーやカメラホールにアプリが重なるのでWidgetをSafeAreaっぽいので囲う
  - battery_plus、screen_brightnessの動作が怪しいので出来ることなら消したい
    - battery_plusは環境最新版4.1.0を適用すると、kotlinとjetField(?)でクラスが衝突して怒られる
    - screen_brightnessかbattery_plusで`Tried to send a platform message to Flutter, but FlutterJNI was detached from native C++. Could not send. Channel: com/event. Response ID: **`というエラーが多発する
  - providerでautoDisposeしてないものがないか確認
    - config等のアプリ起動中使い続けるものはautoDispose不要
- スケジュール
  - ~~スケジュール、タスクを追加する際にindexを指定出来るようにする~~
    - 手動で並び替え出来るようにしたので今のところ不要かと思う
  - iterableになってるschedulesおよびtasksのindexを取得できるようにする
    - tasksは実装した
- Remain
  - スケジュールもタスクも元はListだけど、Jsonから変換する際にIterableにしてるため、順不同になるかもしれない
  - 上下ボタンを関数型にする
    - クラスにすると引数の受け渡し多くて面倒
    - どうせここでしか使わないのでクラスにする必要はない
  - 前後のタスク情報をどこかに小さく表示しても面白い
  - タスクのメモ、時間、自動送りをPaddingで隙間あける
  - タスクの編集時にメモにAutoFocusするのやめた方がいいかも
  - スマホだとレイアウトが崩れる
    - メモを編集する時にキーボードが画面下部ではなく、何故か右下に変な形で表示される
  - スマホでメモを編集時に文字変換確定前（文字に下線が出てる状態）にフォーカスアウトすると編集内容が反映されない
    - 文字変換確定を持って編集完了と見なしても問題ないと思うので、余裕があったら直す
  - ~~自動送りがうまくいかない~~
    - 残り時間が0になった瞬間_remainTimeProviderから選択中のタスクを次のタスクに更新しようとするとエラーが発生する
      - これはprovider内でproviderを更新できないため
    - またbuild中にproviderを更新しようとしてもエラーが発生する
      - これもbuild中にproviderの更新は禁止されているため
        - 一応Future(() {...}))といった非同期処理であれば更新可能だが、buildが完了してから更新処理が走るので、一瞬タイムオーバー画面がちらつく
    - FutureBuilderとか使うといいらしい？
    - provider内でlistenして更新するとうまくいったので様子見
      - 軽く確認した限り provider > listen > build > addPostFrameCallback の順番で実行されるので、listenで更新すれば再度providerから評価していくので問題なさそうに思える
  - ~~カウントダウンが正しいテンポで行われていない~~
    - 更新頻度が高すぎて表示が間に合ってない可能性を考慮し、時間表示部分だけ別クラスに分けて様子見

## スケジュールのオブジェクト構造

```json
{
  "id": "uuid4",
  "schedules": [
    {
      "id": "UUID4",
      "name": "schedule_name",
      "tasks": [
        {
          "id": "UUID4",
          "memo": "task_memo",
          "time": "hh:mm:ss",
          "auto": true,
          "createAt": "(DateTime)",
          "updateAt": "(DateTime)"
        }
      ],
      "createAt": "(DateTime)",
      "updateAt": "(DateTime)"
    }
  ],
  "createAt": "(DateTime)",
  "updateAt": "(DateTime)"
}
```
