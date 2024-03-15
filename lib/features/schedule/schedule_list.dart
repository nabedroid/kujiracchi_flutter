import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:kujiracchi_dart/features/schedule/schedule.dart';

class ScheduleList {
  final String id;
  final Iterable<Schedule> schedules;
  final DateTime createAt;
  final DateTime updateAt;

  const ScheduleList._({required this.id, required this.schedules, required this.createAt, required this.updateAt});

  factory ScheduleList({Iterable<Schedule>? schedules, DateTime? createAt, DateTime? updateAt}) {
    final now = DateTime.now();
    return ScheduleList._(
      id: Uuid().v4(),
      schedules: schedules ?? [],
      createAt: createAt ?? now,
      updateAt: updateAt ?? now,
    );
  }

  factory ScheduleList.fromJson(Map<String, dynamic> json) {
    return ScheduleList._(
      id: json['id'],
      schedules: json['schedules'].isEmpty ? [] : json['schedules'].map<Schedule>((schedule) => Schedule.fromJson(schedule)),
      createAt: DateTime.parse(json['createAt']).toLocal(),
      updateAt: DateTime.parse(json['updateAt']).toLocal(),
    );
  }

  factory ScheduleList.fromSharedPreferences(SharedPreferences sp) {
    if (sp.getString('schedules') == null) {
      return ScheduleList();
    } else {
      final jsonString = sp.getString('schedules')!;
      final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ScheduleList.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'createAt': createAt,
      'updateAt': updateAt,
    };
  }

  ScheduleList copyWith({Iterable<Schedule>? schedules, DateTime? createAt, DateTime? updateAt}) {
    return ScheduleList._(
      // ignore: unnecessary_this
      id: this.id,
      schedules: schedules ?? this.schedules,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? DateTime.now(),
    );
  }
  
  Schedule getSchedule({required String id}) {
    return schedules.singleWhere((schedule) => schedule.id == id);
  }

  ScheduleTask getScheduleTask({String? scheduleId ,required String taskId}) {
    ScheduleTask? result;
    if (scheduleId == null) {
      for (final schedule in schedules) {
        result = schedule.tasks.singleWhereOrNull((task) => task.id == taskId);
        if (result != null) break;
      }
    } else {
      final schedule = getSchedule(id: scheduleId);
      result = schedule.tasks.singleWhereOrNull((task) => task.id == taskId);
    }
    if (result == null) {
      throw StateError('指定されたタスクIDが見つかりません。 taskId:${taskId}');
    }
    return result;
  }

  @override
  String toString() {
    return json.encode(toJson(), toEncodable: (item) => item is DateTime ? item.toUtc().toIso8601String() : item);
  }

  /*
  int get count => _scheduleList.length;
  List<String> get scheduleNames => _scheduleList.map((schedule) => schedule.name).toList();

  Schedule get(int index) => _scheduleList[index];
  List<Schedule> getAll() => _scheduleList;

  void add(Schedule schedule) {
    _scheduleList.add(schedule);
    schedule.addListener(_update);
    _update();
  }

  void remove(Schedule schedule) {
    _scheduleList.remove(schedule);
    schedule.removeListener(_update);
    _update();
  }

  void _update() {
    _sp?.setString('schedules', jsonEncode(toJson()['schedules']));
    notifyListeners();
  }
  */
}