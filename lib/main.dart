import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  Map<String, dynamic> toMap() => {
    'title': title,
    'isDone': isDone,
  };

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      isDone: map['isDone'],
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  // Controller to read text from TextField
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(_filterTask);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = _tasks.map((task) => task.toMap()).toList();
    prefs.setString('tasks', jsonEncode(taskList));
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('tasks');

    if(storedData != null) {
      final List decoded = jsonDecode(storedData);
      setState(() {
        _tasks.clear();
        _tasks.addAll(decoded.map((e) => Task.fromMap(e)).toList());
        _filteredTasks = List.from(_tasks);
      });
    }
  }

  void _filterTask(){
    String query = _searchController.text.trim().toLowerCase();

    setState(() {
      if(query.isEmpty){
        _filteredTasks = List.from(_tasks);
      } else {
        _filteredTasks = _tasks
          .where((task) => task.title.toLowerCase().contains(query))
          .toList();
      }
    });
  }

  // Simple function for the add button
  void _addTask() {
    String text = _taskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: text));
        _filteredTasks = List.from(_tasks);
        _taskController.clear(); // Clear input after adding
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index){
    final deletedTask = _tasks[index];
    final actualIndex = _tasks.indexOf(deletedTask);

    setState(() {
      _tasks.removeAt(index);
      _filteredTasks.removeAt(index);
    });
    _saveTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: "${deletedTask.title}"'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo', 
          onPressed: () {
            setState(() {
              _tasks.insert(index, deletedTask); 
              _filteredTasks = List.from(_tasks);             
            });
            _saveTasks();
          }
        ),
      )
    );
  }

  void _toggleTask(int index){
    final task = _filteredTasks[index];
    final realIndex = _tasks.indexOf(task);

    setState(() {
      _tasks[index].isDone = ! _tasks[index].isDone;
      _filteredTasks[index].isDone = !_filteredTasks[index].isDone;
    });
    _saveTasks();
  }

  void _editTask(int index) {
    final task = _tasks[index];
    final actualIndex = _tasks.indexOf(task);
    final editController = TextEditingController(text: task.title);

    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new task name'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
            setState(() {
              _tasks[actualIndex].title = editController.text.trim();
              _filteredTasks[index].title = editController.text.trim();
            });
            _saveTasks();
            Navigator.pop(context);
          }, 
          child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                )
              ),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Enter a task...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add_rounded, size: 30, color: Colors.grey[800]),
                        onPressed: _addTask,
                        tooltip: 'Add Task',
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
              ],
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
                      key: UniqueKey(),
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
                        if(direction == DismissDirection.startToEnd) {
                          _deleteTask(index);
                          return true;
                        } else if (direction == DismissDirection.endToStart) {
                          _editTask(index);
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
                              color: task.isDone
                                ? Colors.grey
                                : Colors.black,
                              decoration: task.isDone 
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            ),
                          ),
                          onTap: () => _toggleTask(index),
                        ),
                      ),
                    );
                  },
                )
            )
          ],
        ),
      ),
    );
  }
}
