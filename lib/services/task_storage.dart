import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/task.dart';

class TaskStorage {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _database async {
    return _appDatabase.database;
  }

  Future<List<Task>> getTasks() async {
    final db = await _database;

    final result = await db.query('tasks', orderBy: 'id DESC');

    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> addTask(Task task) async {
    final db = await _database;

    final map = task.toMap();
    map.remove('id');

    return db.insert('tasks', map);
  }

  Future<int> updateTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('Task ID is required for updating.');
    }

    final db = await _database;
    final map = task.toMap();
    map.remove('id');

    return db.update('tasks', map, where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await _database;

    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> searchTasks(String query) async {
    final db = await _database;

    final result = await db.query(
      'tasks',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'id DESC',
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }
}
