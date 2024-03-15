import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String task;

  const Task(this.id, this.task);

  Task copyWith({String? id, String? task}) {
    return Task(id ?? this.id, task ?? this.task);
  }
}

class Data {
  final String id;
  final String value;
  final List<Task> tasks;

  const Data(this.id, this.value, this.tasks);

  Data copyWith({String? id, String? value, List<Task>? tasks}) {
    return Data(id ?? this.id, value ?? this.value, tasks ?? this.tasks);
  }
}

class DataNotifier extends StateNotifier<Data?> {
  DataNotifier(Data? d) : super(d);

  set id(String id) => state = state?.copyWith(id: id);

  set value(String value) => state = state?.copyWith(value: value);

  void add(Task task) =>
      state = state?.copyWith(tasks: [...state!.tasks, task]);

  void remove(Task task) => state = state?.copyWith(tasks: state!.tasks.where((t) => t.id != task.id).toList());

  void update(Task task) => state = state?.copyWith(
      tasks: state!.tasks.map((t) => t.id == task.id ? task : t).toList());
}

class DataListNotifier extends StateNotifier<List<Data>> {
  DataListNotifier() : super([]);

  void add(Data data) {
    state = [...state, data];
  }

  void remove(Data data) {
    state = state.where((d) => d != data).toList();
  }

  void update(Data data) {
    state = state.map((d) => d.id == data.id ? data : d).toList();
  }
}

final dataListProvider =
    StateNotifierProvider<DataListNotifier, List<Data>>((ref) {
  return DataListNotifier();
});

final dataProvider = StateNotifierProvider.autoDispose
    .family<DataNotifier, Data?, String?>((ref, id) {
  final dataList = ref.watch(dataListProvider);
  int index = dataList.indexWhere((data) => data.id == id);
  return index >= 0 ? DataNotifier(dataList[index]) : DataNotifier(null);
});

final selectIdProvider = StateProvider.autoDispose<String?>((ref) => null);

class TimerPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataList = ref.watch(dataListProvider);
    final selectId = ref.watch(selectIdProvider);
    final data = ref.watch(dataProvider(selectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  final addData = Data(Uuid().v4(), 'value', []);
                  ref.read(dataListProvider.notifier).add(addData);
                },
                child: const Text('Add'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (data != null) {
                    Data d = data;
                    ref.read(selectIdProvider.notifier).state = null;
                    ref.read(dataListProvider.notifier).remove(d);
                  }
                },
                child: const Text('Remove'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (data != null) {
                    ref.read(dataListProvider.notifier).update(
                        data.copyWith(value: '${Random().nextInt(100)}'));
                  }
                },
                child: const Text('rename'),
              ),
            ],
          ),
          DropdownButton(
            value: selectId,
            items: [
              for (Data data in dataList)
                DropdownMenuItem(
                    value: data.id,
                    child: Text(
                        'id: ${data.id.substring(0, 3)} value: ${data.value} tasks: ${data.tasks.length}]')),
            ],
            onChanged: (Object? value) {
              ref.read(selectIdProvider.notifier).state = value as String?;
            },
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(dataProvider(selectId).notifier)
                      .add(Task(Uuid().v4(), 'new task'));
                },
                child: const Text('Add'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Remove'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Edit'),
              ),
            ],
          ),
          SizedBox(
            width: 500,
            height: 200,
            child: ListView(
              children: [
                if (data != null)
                  for (Task task in data.tasks)
                    Text('id: ${task.id} task: ${task.task}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
