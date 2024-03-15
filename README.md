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
  - くじらを表示する
  - 画面右上の戻るボタンをくじらを引っ張って戻る方式にする
  - ボタンを押した際にアイコン部分だけエフェクト（Ink）出したい
    - 現状ボタン判定領域一杯にエフェクトが出て違和感を感じる
  - スケジュール、設定の保存先をSharedPreferences以外に変えたい
    - SPだとアプリやブラウザのアップデートやキャッシュクリアで消えそう
    - Driftとか良いらしい
    - 旧バージョンだとSDカードで管理してるらしいが・・・本当か・・・？
- スケジュール
  - スケジュール、タスクを追加する際にindexを指定出来るようにする
  - iterableになってるschedulesおよびtasksのindexを取得できるようにする
- Remain
  - スケジュールの選択および編集を画面左のアコーディオンでやりたい
    - イメージはGmail
  - スケジュールもタスクも元はListだけど、Jsonから変換する際にIterableにしてるため、順不同になるかもしれない
  - タスクの並び替えを実装する
  - 上下ボタンを関数型にする
    - クラスにすると引数の受け渡し多くて面倒
    - どうせここでしか使わないのでクラスにする必要はない
  - タスクの設定時刻を表示
  - 前後のタスク情報をどこかに小さく表示しても面白い
  - 

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
