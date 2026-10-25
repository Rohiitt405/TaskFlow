import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_storage.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskStorage? taskStorage})
    : _taskStorage = taskStorage ?? TaskStorage();

  final TaskStorage _taskStorage;
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> loadTasks() async {
    final loadedTasks = await _taskStorage.getTasks();

    _tasks
      ..clear()
      ..addAll(loadedTasks);

    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final text = title.trim();

    if (text.isEmpty) return;

    final task = Task(title: text);
    final id = await _taskStorage.addTask(task);

    _tasks.add(task.copyWith(id: id));
    notifyListeners();
  }

  Future<void> addTasks(List<String> titles) async {
    for (final title in titles) {
      await addTask(title);
    }
  }

  Future<void> deleteTask(Task task) async {
    final id = task.id;
    if (id == null) return;

    await _taskStorage.deleteTask(id);

    _tasks.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> restoreTask(Task task) async {
    final restoredTask = Task(
      title: task.title,
      isDone: task.isDone,
      createdAt: task.createdAt,
    );

    final id = await _taskStorage.addTask(restoredTask);

    _tasks.add(restoredTask.copyWith(id: id));
    notifyListeners();
  }

  Future<void> toggleTask(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) return;

    final updatedTask = _tasks[index].copyWith(isDone: !_tasks[index].isDone);

    await _taskStorage.updateTask(updatedTask);

    _tasks[index] = updatedTask;
    notifyListeners();
  }

  Future<void> editTask(Task task, String newTitle) async {
    final title = newTitle.trim();

    if (title.isEmpty) return;

    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) return;

    final updatedTask = _tasks[index].copyWith(title: title);

    await _taskStorage.updateTask(updatedTask);

    _tasks[index] = updatedTask;
    notifyListeners();
  }

  List<Task> searchTasks(String query) {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) return tasks;

    return _tasks
        .where((task) => task.title.toLowerCase().contains(text))
        .toList();
  }
}
