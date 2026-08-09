import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_storage.dart';

class TaskController extends ChangeNotifier {
  TaskController({
    required TaskStorage? taskStorage,
  }) : _taskStorage = taskStorage ?? TaskStorage();

  final TaskStorage _taskStorage;
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> loadTasks() async {
    final loadedTasks = await _taskStorage.loadTasks();

    _tasks
      ..clear()
      ..addAll(loadedTasks);

    notifyListeners();
  }

  Future<void> saveTasks() async {
    await _taskStorage.saveTasks(_tasks);
  }

  Future<void> addTask(String title) async {
    final text = title.trim();

    if (text.isEmpty) {
      return;
    }

    _tasks.add(
      Task(
        id: _createTaskId(),
        title: text,
      ),
    );

    await saveTasks();
    notifyListeners();
  }

  Future<void> addTasks(List<String> titles) async {
    for (final title in titles) {
      final text = title.trim();

      if(text.isEmpty) {
        continue;
      }

      _tasks.add(
        Task(
          id: _createTaskId(), 
          title: text
        ),
      );

      await saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere(
      (item) => item.id == task.id,
    );

    await saveTasks();
    notifyListeners();
  }

  String _createTaskId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> restoreTask(Task task) async {
    _tasks.add(task);

    await saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(Task task) async {
    final taskToUpdate = _tasks.firstWhere(
      (item) => item.id == task.id,
    );

    taskToUpdate.isDone = !taskToUpdate.isDone;

    await saveTasks();
    notifyListeners();
  }

  Future<void> editTask(
    Task task,
    String newTitle,
  ) async {
    final title = newTitle.trim();

    if (title.isEmpty) {
      return;
    }

    final taskToUpdate = _tasks.firstWhere(
      (item) => item.id == task.id,
    );

    taskToUpdate.title = title;

    await saveTasks();
    notifyListeners();
  }
}