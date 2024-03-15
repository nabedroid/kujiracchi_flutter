import 'package:uuid/uuid.dart';

class ScheduleTask {
  final String id;
  final String memo;
  final String time;
  final bool auto;
  final DateTime createAt;
  final DateTime updateAt;

  const ScheduleTask._({required this.id, required this.memo, required this.time, required this.auto, required this.createAt, required this.updateAt});

  factory ScheduleTask({String? memo, String? time, bool? auto, DateTime? createAt, DateTime? updateAt}) {
    final now = DateTime.now();
    return ScheduleTask._(
      id: Uuid().v4(),
      memo: memo ?? '',
      time: time ?? '',
      auto: auto ?? true,
      createAt: createAt ?? now,
      updateAt: updateAt ?? now,
    );
  }

  factory ScheduleTask.fromJson(Map<String, dynamic> json) {
    return ScheduleTask._(
      id: json['id'],
      memo: json['memo'],
      time: json['time'],
      auto: json['auto'],
      createAt: DateTime.parse(json['createAt']).toLocal(),
      updateAt: DateTime.parse(json['updateAt']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'memo': memo, 'time': time, 'auto': auto, 'createAt': createAt, 'updateAt': updateAt};
  }

  ScheduleTask copyWith({String? memo, String? time, bool? auto, DateTime? createAt, DateTime? updateAt}) {
    return ScheduleTask._(
      // ignore: unnecessary_this
      id: this.id,
      memo: memo ?? this.memo,
      time: time ?? this.time,
      auto: auto ?? this.auto,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }
}