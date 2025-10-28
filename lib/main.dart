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

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  // Controller to read text from TextField
  final TextEditingController _controller = TextEditingController();

  // Simple function for the add button
  void _addTask() {
    String taskText = _controller.text.trim();
    if (taskText.isNotEmpty) {
      print("Task added: $taskText"); // For now, just print to console
      _controller.clear(); // Clear input after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do App 📝'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
            FloatingActionButton.small(
              onPressed: _addTask,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
