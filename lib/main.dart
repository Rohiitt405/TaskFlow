import 'package:flutter/material.dart';

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

  // Simple function for the add button
  void _addTask() {
    String taskText = _controller.text.trim();
    if (taskText.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: taskText));
        _controller.clear(); // Clear input after adding
      });
    }
  }

  void _deleteTask(int index){
    final deletedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });

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
          }
        ),
      )
    );
  }

  void _toggleTask(int index){
    setState(() {
      _tasks[index].isDone = ! _tasks[index].isDone;
    });
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
        title: const Text('ToDo List'),
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
                    return Card(
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

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTask(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red,),
                              onPressed: () => _deleteTask(index),
                            )
                          ],
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
