import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/task.dart';
import '../services/audio_service.dart';
import '../services/task_storage.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final AudioService _audioService = AudioService();
  final TaskStorage _taskStorage = TaskStorage();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Task> _tasks = <Task>[];
  final List<Task> _filteredTasks = <Task>[];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTasks);
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTasks);
    _searchController.dispose();
    _taskController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await _taskStorage.loadTasks();

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks
        ..clear()
        ..addAll(loadedTasks);
      _filteredTasks
        ..clear()
        ..addAll(_applyFilter(_searchController.text.trim().toLowerCase()));
    });
  }

  Future<void> _saveTasks() async {
    await _taskStorage.saveTasks(_tasks);
  }

  Future<void> _playSound(String path) async {
    await _audioService.play(path);
  }

  List<Task> _applyFilter(String query) {
    if (query.isEmpty) {
      return List<Task>.from(_tasks);
    }

    return _tasks.where((task) => task.title.toLowerCase().contains(query)).toList();
  }

  void _filterTasks() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredTasks
        ..clear()
        ..addAll(_applyFilter(query));
    });
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _playSound('sounds/Search.mp3');
      } else {
        _searchController.clear();
        _filteredTasks
          ..clear()
          ..addAll(_applyFilter(''));
      }
    });
  }

  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _tasks.add(Task(id: _createTaskId(), title: text));
      _filteredTasks
        ..clear()
        ..addAll(_applyFilter(_searchController.text.trim().toLowerCase()));
      _taskController.clear();
    });

    await _saveTasks();
    await _playSound('sounds/Add.mp3');
  }

  Future<void> _addTasksFromImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        return;
      }

      final File imageFile = File(pickedFile.path);
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(
          InputImage.fromFile(imageFile),
        );
        final extractedText = recognizedText.text.trim();
        final taskLines = extractedText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        if (taskLines.isEmpty) {
          _showMessage('No valid tasks found in the image.');
          return;
        }

        setState(() {
          for (final line in taskLines) {
            _tasks.add(Task(id: _createTaskId(), title: line));
          }
          _filteredTasks
            ..clear()
            ..addAll(_applyFilter(_searchController.text.trim().toLowerCase()));
        });

        await _saveTasks();
        await _playSound('sounds/Add.mp3');
        _showMessage('Added ${taskLines.length} task${taskLines.length == 1 ? '' : 's'} from image.');
      } finally {
        await textRecognizer.close();
      }
    } catch (error) {
      _showMessage('Error: $error');
    }
  }

  void _deleteTask(Task task) {
    final deletedTask = task.copyWith();

    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
      _filteredTasks.removeWhere((item) => item.id == task.id);
    });

    _saveTasks();
    _playSound('sounds/Delete.mp3');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: "${task.title}"'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _tasks.add(deletedTask);
              _filteredTasks
                ..clear()
                ..addAll(_applyFilter(_searchController.text.trim().toLowerCase()));
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  void _toggleTask(Task task) {
    final taskToUpdate = _tasks.firstWhere((item) => item.id == task.id);

    setState(() {
      taskToUpdate.isDone = !taskToUpdate.isDone;
      task.isDone = taskToUpdate.isDone;
    });

    _saveTasks();
  }

  void _editTask(Task task) {
    final editController = TextEditingController(text: task.title);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter new task name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = editController.text.trim();
                if (newTitle.isEmpty) {
                  return;
                }

                setState(() {
                  final taskToUpdate = _tasks.firstWhere((item) => item.id == task.id);
                  taskToUpdate.title = newTitle;
                  task.title = newTitle;
                });

                _saveTasks();
                _playSound('sounds/Edit.mp3');
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _createTaskId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: TextField(
                controller: _isSearching ? _searchController : _taskController,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _isSearching ? (_) => _filterTasks() : null,
                onSubmitted: (value) {
                  if (_isSearching) {
                    _filterTasks();
                  } else {
                    _addTask();
                  }
                },
                decoration: InputDecoration(
                  hintText: _isSearching ? 'Search tasks...' : 'Enter a task...',
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.search_rounded,
                      color: _isSearching ? Colors.blue : Colors.grey[800],
                    ),
                    onPressed: _toggleSearchMode,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.camera_sharp, size: 26),
                        tooltip: 'Add from Image',
                        onPressed: _addTasksFromImage,
                      ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close_rounded : Icons.add_rounded,
                          color: Colors.grey[800],
                          size: 28,
                        ),
                        tooltip: _isSearching ? 'Close search' : 'Add Task',
                        onPressed: () {
                          if (_isSearching) {
                            _toggleSearchMode();
                          } else {
                            _addTask();
                          }
                        },
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks found!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];

                        return Dismissible(
                          key: ValueKey(task.id),
                          background: Container(
                            color: Colors.red[400],
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.blue[400],
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              _deleteTask(task);
                              return true;
                            }
                            if (direction == DismissDirection.endToStart) {
                              _editTask(task);
                              return false;
                            }
                            return false;
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: task.isDone ? Colors.grey : Colors.black,
                                  decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                              onTap: () => _toggleTask(task),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
