import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Controller to read text from TextField
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(_filterTask);
  }

  Future<void> _addTasksFromImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

      if(pickedFile == null)  return;

      final File imageFile = File(pickedFile.path);
      final textRecognizer = TextRecognizer();

      final RecognizedText recognizedText = await textRecognizer.processImage(InputImage.fromFile(imageFile));

      await textRecognizer.close();

      final extractedText = recognizedText.text.trim();

      if(extractedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text detected in the image.')),
        );
        return;
      }

      final List<String> taskLines = extractedText.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

      if(taskLines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid tasks found in image.')),
        );
        return;
      }

      setState(() {
        for(var line in taskLines){
          _tasks.add(Task(title: line));
        }
        _filteredTasks = List.from(_tasks);
      });

      await _saveTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${taskLines.length} image!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _playSound(String path) async {
    await _audioPlayer.play(AssetSource(path));
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
      _playSound('sounds/Add.mp3');
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
    _playSound('sounds/Delete.mp3');

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
      _tasks[realIndex].isDone = ! _tasks[realIndex].isDone;
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
            _playSound('sounds/Edit.mp3');
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
    _searchController.removeListener(_filterTask);
    _searchController.dispose();
    _taskController.dispose();
    _audioPlayer.dispose();
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: TextField(
                controller: _isSearching ? _searchController : _taskController,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _isSearching ? (_) => _filterTask() : null,
                onSubmitted: (value) {
                  if(_isSearching){
                    _filterTask();
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
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (_isSearching){
                          _playSound('sounds/Search.mp3');
                        } else {
                          _searchController.clear();
                          _filteredTasks = List.from(_tasks);
                        }
                      });
                    },
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_sharp, size: 26),
                        tooltip: 'Add from Image',
                        onPressed: _addTasksFromImage,
                      ),
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close_rounded : Icons.add_rounded,
                        color: Colors.grey[800],
                        size: 28
                        ),
                        tooltip: _isSearching ? 'Close search' : 'Add Task',
                        onPressed: () {
                          if (_isSearching){
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              _filteredTasks = List.from(_tasks);
                            });
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
