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
  final TextEditingController _controller = TextEditingController();
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
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
      });
    }
  }

  // Simple function for the add button
  void _addTask() {
    String taskText = _controller.text.trim();
    if (taskText.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: taskText));
        _controller.clear(); // Clear input after adding
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index){
    final deletedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
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
            });
            _saveTasks();
          }
        ),
      )
    );
  }

  void _toggleTask(int index){
    setState(() {
      _tasks[index].isDone = ! _tasks[index].isDone;
    });
    _saveTasks();
  }

  void _editTask(int index) {
    final task = _tasks[index];
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
              task.title = editController.text.trim();
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
            Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Enter a task...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                // Add button
                FloatingActionButton(
                  onPressed: _addTask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _tasks.isEmpty
                ? const Center(
                  child: Text(
                    'No tasks yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];

                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red[400],
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 15),

                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),

                      secondaryBackground: Container(
                        color: Colors.blue[400],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 15),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: Colors.white)),
                          ],
                        ),
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
