import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final Future<String> scheduleFileDirectoryPath = () async {
  final dirPath = (await getApplicationDocumentsDirectory()).path;
  return '$dirPath/schedules';
}();

class ScheduleFileList extends ChangeNotifier {

  List<File> _scheduleFileList = <File>[];

  int get count => _scheduleFileList.length;
  Iterator<File> get iterator => _scheduleFileList.iterator;

  ScheduleFileList();

  int indexOf(File file) {
    return _scheduleFileList.indexOf(file);
  }

  File get(int index) {
    return _scheduleFileList[index];
  }

  void add(File file) {
    _scheduleFileList.add(file);
    file.createSync();
    notifyListeners();
  }

  void remove(File file) {
    _scheduleFileList.remove(file);
    file.deleteSync();
    notifyListeners();
  }
}

final scheduleFileListProvider = FutureProvider.autoDispose<ScheduleFileList>((ref) async {
  final scheduleFileList = ScheduleFileList();
  // ローカルファイルからスケジュールファイル一覧を取得する
  final dir = Directory(await scheduleFileDirectoryPath);

  if (dir.existsSync() == false) {
    dir.createSync();
  }

  for (final entity in dir.listSync()) {
    if (entity is File) {
      scheduleFileList.add(entity);
    }
  }

  return scheduleFileList;
});
