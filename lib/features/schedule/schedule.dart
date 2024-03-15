import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:kujiracchi_dart/features/schedule/schedule_task.dart';

class Schedule {

  final String id;
  final String name;
  final Iterable<ScheduleTask> tasks;
  final DateTime createAt;
  final DateTime updateAt;

  Schedule._({required this.id, required this.name, required this.tasks, required this.createAt, required this.updateAt});

  factory Schedule({required String name, Iterable<ScheduleTask>? tasks, DateTime? createAt, DateTime? updateAt}) {
    final now = DateTime.now();
    return Schedule._(
      id: Uuid().v4(),
      name: name,
      tasks: tasks ?? [],
      createAt: createAt ?? now,
      updateAt: updateAt ?? now,
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule._(
      id: json['id'],
      name: json['name'],
      tasks: json['tasks'].isEmpty ? [] : json['tasks'].map<ScheduleTask>((task) => ScheduleTask.fromJson(task)),
      createAt: DateTime.parse(json['createAt']).toLocal(),
      updateAt: DateTime.parse(json['updateAt']).toLocal(),
    );
  }

  Schedule copyWith({String? name, Iterable<ScheduleTask>? tasks, DateTime? createAt, DateTime? updateAt}) {
    return Schedule._(
      // ignore: unnecessary_this
      id: this.id,
      name: name ?? this.name,
      tasks: tasks ?? this.tasks,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createAt': createAt,
      'updateAt': updateAt,
    };
  }

  String toJsonString() {
    return json.encode(toJson(), toEncodable: (item) => item is DateTime ? item.toIso8601String() : item);
  }

}

  /*
  const Schedule.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    final tasks = json['tasks'];
    for (Map<String, dynamic> task in tasks) {
      add(ScheduleTask.fromJson(task));
    }
  }

  void _fromJson(Map<String, dynamic> json) {
  }

  Schedule.fromJsonString(String json) : this.fromJson(jsonDecode(json));

  String get name => _name;
  set name(String n) {
    if (_name != n) {
      _name = n;
      notifyListeners();
    }
  }

  int get count => _taskList.length;

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'tasks': _taskList.map((task) => task.toJson()).toList(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  void add(ScheduleTask task) {
    _taskList.add(task);
    task.addListener(_updateSchedule);
    notifyListeners();
  }

  void remove(ScheduleTask task) {
    _taskList.remove(task);
    task.removeListener(_updateSchedule);
    notifyListeners();
  }

  // リスト内のnotifyを外部に伝播させる方法が分からなかったので一先ず無理やり実装
  void _updateSchedule() {
    notifyListeners();
  }
   */
