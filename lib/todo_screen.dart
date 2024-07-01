import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_helper.dart'; // Import the database helper
import 'welcome.dart';
import 'utils.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoggedIn = false;
  String _accessToken = '';

  @override
  void initState() {
    super.initState();
    print('Initializing TodoScreen');
    Utils.checkLoginStatus().then((loggedIn) {
      print('Login status: $loggedIn');
      if (loggedIn) {
        _restoreLoginStatus();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      }
    });
  }

  Future<void> _restoreLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken != null) {
      setState(() {
        _accessToken = accessToken;
        _isLoggedIn = true;
      });
      print('Restored access token: $_accessToken');
      _fetchAndCacheItems();
    }
  }

  Future<void> _fetchAndCacheItems() async {
    if (kIsWeb) {
      print('Fetch and cache items not supported on web');
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/v1/items/?skip=0&limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> items = jsonDecode(response.body);
        List<Task> tasks = items.map((item) => Task.fromJson(item)).toList();
        await _dbHelper.insertTasks(tasks); // Save to local SQLite
        _fetchItemsFromLocal();
      } else {
        print('Failed to fetch items from server: ${response.body}');
        _fetchItemsFromLocal();
      }
    } catch (e) {
      print('Error fetching items from server: $e');
      _fetchItemsFromLocal();
    }
  }

  Future<void> _fetchItemsFromLocal() async {
    print('Fetching items from local database');
    List<Task> tasks = await _dbHelper.fetchTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(tasks);
      _sortTasks();
    });
    print('Fetched tasks: $_tasks');
  }

  Future<void> _addTask(String title, String description) async {
    if (title.isNotEmpty && description.isNotEmpty) {
      if (kIsWeb) {
        print('Add task not supported on web');
        return;
      }
      Task newTask = Task(id: 0, title: title, description: description, isDone: false);
      print('Adding task: $newTask');
      await _dbHelper.insertTask(newTask);
      _fetchItemsFromLocal(); // Refresh the list after adding
    }
  }

  Future<void> _toggleDone(int id) async {
    if (kIsWeb) {
      print('Toggle task done status not supported on web');
      return;
    }
    var task = _tasks.firstWhere((t) => t.id == id);
    task.isDone = !task.isDone;
    print('Toggling task done status: $task');
    await _dbHelper.updateTask(task);
    _fetchItemsFromLocal(); // Refresh the list after updating
  }

  Future<void> _removeTask(int id) async {
    if (kIsWeb) {
      print('Remove task not supported on web');
      return;
    }
    print('Removing task with id: $id');
    await _dbHelper.deleteTask(id);
    _fetchItemsFromLocal(); // Refresh the list after deleting
  }

  Future<void> _updateTask(int id, String title, String description, bool isDone) async {
    if (kIsWeb) {
      print('Update task not supported on web');
      return;
    }
    var task = Task(id: id, title: title, description: description, isDone: isDone);
    print('Updating task: $task');
    await _dbHelper.updateTask(task);
    _fetchItemsFromLocal(); // Refresh the list after updating
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);

    Utils.showDialogGeneric(
      context: context,
      title: 'Edit Task',
      fields: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'Description'),
        ),
      ],
      onConfirm: () => _updateTask(
        task.id,
        titleController.text,
        descriptionController.text,
        task.isDone,
      ),
    );
  }

  void logout(BuildContext context, VoidCallback onLogoutSuccess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    print('Logged out and removed access token');
    onLogoutSuccess();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  void _handleLogoutSuccess() {
    _isLoggedIn = false;
    _tasks.clear();
    setState(() {});
    print('Handled logout success');
  }

  void _sortTasks() {
    setState(() {
      _tasks.sort((a, b) {
        if (a.isDone && !b.isDone) return 1;
        if (!a.isDone && b.isDone) return -1;
        return b.id.compareTo(a.id); // Assuming higher IDs are newer tasks
      });
    });
    print('Sorted tasks: $_tasks');
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Utils.showDialogGeneric(
      context: context,
      title: 'Add Task',
      fields: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'Description'),
        ),
      ],
      onConfirm: () => _addTask(
        titleController.text,
        descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        leading: SizedBox(
          width: 100, // Adjust the width as needed
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 1), // Adjust padding as needed
              minimumSize: Size(150, 50), // Adjust minimum size as needed
            ),
            onPressed: () => logout(context, _handleLogoutSuccess),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Dismissible(
            key: Key(task.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _removeTask(task.id);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Text(
                '${index + 1}', // Display the item number
                style: TextStyle(fontSize: 15), 
              ), 
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    iconSize: 18, // Smaller icon size
                    onPressed: () => _showEditTaskDialog(context, task),
                  ),
                  IconButton(
                    icon: Icon(
                      task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                    ),
                    onPressed: () => _toggleDone(task.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                _showAddTaskDialog(context);
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class Task {
  int id;
  String title;
  String description;
  bool isDone;

  Task({required this.id, required this.title, required this.description, this.isDone = false});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0, // SQLite stores booleans as integers (0 and 1)
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['is_done'] == 1, // SQLite stores booleans as integers (0 and 1)
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, isDone: $isDone}';
  }
}
