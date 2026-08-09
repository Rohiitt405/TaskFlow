import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../services/audio_service.dart';
import '../services/image_task_service.dart';
import '../helpers/snackbar_helper.dart';
import '../constants/app_sounds.dart';
import '../services/task_storage.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final AudioService _audioService = AudioService();
  final TaskController _taskController = TaskController(
    taskStorage: TaskStorage(),
  );
  final ImageTaskService _imageTaskService = ImageTaskService();

  final TextEditingController _taskInputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<Task> _tasks = <Task>[];
  final List<Task> _filteredTasks = <Task>[];
  bool _isSearching = false;
  int _selectedIndex = 1;

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
    _taskInputController.dispose();
    _audioService.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _syncTaskFromController() {
    _tasks
      ..clear()
      ..addAll(_taskController.tasks);

    _refreshFilteredTasks();
  }

  void _refreshFilteredTasks() {
    _filteredTasks
      ..clear()
      ..addAll(
        _applyFilter(_searchController.text),
      );
  }

  Future<void> _loadTasks() async {
    await _taskController.loadTasks();

    if (!mounted) {
      return;
    }

    setState(_syncTaskFromController);
  }

  List<Task> _applyFilter(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List<Task>.from(_tasks);
    }

    return _tasks
      .where(
        (task) => task.title.toLowerCase().contains(query)
      )
      .toList();
  }

  void _filterTasks() {
    setState(_refreshFilteredTasks);
  }

  void _toggleSearchMode() {
    setState(() async {
      _isSearching = !_isSearching;
      if (_isSearching) {
        await _audioService.play(AppSounds.search);
      } else {
        _searchController.clear();
        _refreshFilteredTasks();
      }
    });
  }

  Future<void> _addTask() async {
    final text = _taskInputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    await _taskController.addTask(text);

    setState(() {
      _syncTaskFromController();
      _taskInputController.clear();
    });

    await _audioService.play(AppSounds.add);
  }

  Future<void> _addTasksFromImage() async {
    try {
      final taskLines = await _imageTaskService.extractTasksFromCamera();

      if(taskLines.isEmpty) {
        SnackBarHelper.show(
          context, 
          'No valid tasks found in the image.',
        );
        return;
      }

      await _taskController.addTasks(taskLines);

      if(!mounted) {
        return;
      }

      setState(_syncTaskFromController);

      await _audioService.play(AppSounds.add);

      SnackBarHelper.show(
        context,
        'Added ${taskLines.length} task${taskLines.length == 1 ? '' : 's'} from the image.',
      );

    } catch (error) {
      SnackBarHelper.show(
        context,
        'Error: $error'
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    final deletedTask = task.copyWith();

    await _taskController.deleteTask(task);

    if(!mounted) {
      return;
    }

    setState(_syncTaskFromController);

    _audioService.play(AppSounds.delete);

    if(!mounted) {
      return;
    }

    SnackBarHelper.show(
      context,
      'Deleted: "${task.title}"',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          await _taskController.restoreTask(deletedTask);

          if(!mounted) {
            return;
          }

          setState(_syncTaskFromController);
        },
      ),
    );
  }

  Future<void> _toggleTask(Task task) async {
    await _taskController.toggleTask(task);

    if(!mounted) {
      return;
    }

    setState(_syncTaskFromController);
  }

  void _editTask(Task task) {
    final editController = TextEditingController(text: task.title);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFBF9F8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Edit Task',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B1C1C)),
          ),
          content: TextField(
            controller: editController,
            autofocus: true,
            style: const TextStyle(color: Color(0xFF1B1C1C)),
            decoration: const InputDecoration(
              hintText: 'Enter new task name',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1B1C1C)),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF747878))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B1C1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final newTitle = editController.text.trim();
                if (newTitle.isEmpty) {
                  return;
                }

                await _taskController.editTask(
                  task, 
                  newTitle
                );

                if(!mounted) {
                  return;
                }

                setState(_syncTaskFromController);

                await _audioService.play(AppSounds.edit);

                if(!mounted || !context.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      // TopAppBar Component
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Todo List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1C1C),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFC4C7C7),
            height: 1.0,
          ),
        ),
      ),
      // Main Content
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  // Search & Entry Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSearching ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            size: 20,
                            color: _isSearching ? const Color(0xFF0055FF) : const Color(0xFF4A4A4A),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _toggleSearchMode,
                          tooltip: 'Search tasks',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _isSearching ? _searchController : _taskInputController,
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
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B1C1C),
                            ),
                            decoration: InputDecoration(
                              hintText: _isSearching ? 'Search tasks...' : 'Enter a task...',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF444748),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: const Color(0xFFC4C7C7),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined, size: 20),
                          color: const Color(0xFF4A4A4A),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _addTasksFromImage,
                          tooltip: 'Add from Image',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _isSearching ? Icons.close : Icons.add,
                            size: 24,
                          ),
                          color: _isSearching ? const Color(0xFF4A4A4A) : const Color(0xFF0055FF),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (_isSearching) {
                              _toggleSearchMode();
                            } else {
                              _addTask();
                            }
                          },
                          tooltip: _isSearching ? 'Close search' : 'Add task',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tasks List or Empty State Container
                  Expanded(
                    child: _filteredTasks.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 128,
                                height: 128,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5F3F3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.checklist_rtl_rounded,
                                  size: 64,
                                  color: Color(0xFFC4C7C7),
                                ),
                              ),
                              const Text(
                                'No tasks found!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF444748),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(
                                width: 280,
                                child: Text(
                                  'Your workspace is clear. Start by adding a new objective above.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF747878),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _filteredTasks.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];

                              return Dismissible(
                                key: ValueKey(task.id),
                                background: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBA1A1A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(Icons.delete_outline, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF537AFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.edit_outlined, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    await _deleteTask(task);
                                    return true;
                                  }
                                  if (direction == DismissDirection.endToStart) {
                                    _editTask(task);
                                    return false;
                                  }
                                  return false;
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE4E2E2)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: Checkbox(
                                      value: task.isDone,
                                      activeColor: const Color(0xFF1B1C1C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (_) => _toggleTask(task),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: task.isDone ? const Color(0xFF747878) : const Color(0xFF1B1C1C),
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
          ),
        ),
      ),
      // BottomNavBar Shared Component
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBF9F8),
          border: Border(
            top: BorderSide(
              color: Color(0xFFC4C7C7),
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFFFFDAD5).withOpacity(0.5),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt, color: Color(0xFFB71511)),
              selectedIcon: Icon(Icons.list_alt, color: Color(0xFFB71511)),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}