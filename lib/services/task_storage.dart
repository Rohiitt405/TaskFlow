import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  static const String _storageKey = 'tasks';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return <Task>[];
    }

    final decodedData = jsonDecode(storedData);
    if (decodedData is! List) {
      return <Task>[];
    }

    return decodedData
        .map((item) => Task.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) => task.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(taskList));
  }
}
