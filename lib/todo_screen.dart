import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome.dart';
import 'utils.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  bool _isLoggedIn = false;
  String _accessToken = '';

  @override
  void initState() {
    super.initState();
    Utils.checkLoginStatus().then((loggedIn) {
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
      _fetchItems();
    }
  }

  void _addTask(String title, String description) async {
    if (title.isNotEmpty && description.isNotEmpty) {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/v1/items/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'description': description,
          'is_done': false,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          _tasks.add(Task(
              id: responseBody['id'],
              title: title,
              description: description,
              isDone: false));
          _sortTasks();
        });
      } else {
        print('Failed to create item: ${response.body}');
      }
    }
  }

  void _toggleDone(int id) async {
    var task = _tasks.firstWhere((t) => t.id == id);
    var response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/v1/items/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'title': task.title,
        'description': task.description,
        'is_done': !task.isDone,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        task.isDone = !task.isDone;
        _sortTasks();
      });
    } else {
      print('Failed to update item: ${response.body}');
    }
  }

  void _removeTask(int id) async {
    var response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/v1/items/$id'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _tasks.removeWhere((t) => t.id == id);
      });
    } else {
      print('Failed to delete item: ${response.body}');
    }
  }

  void _updateTask(int id, String title, String description, bool isDone) async {
    var response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/v1/items/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'description': description,
        'is_done': isDone,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        var task = _tasks.firstWhere((t) => t.id == id);
        task.title = title;
        task.description = description;
        task.isDone = isDone;
        _sortTasks();
      });
    } else {
      print('Failed to update item: ${response.body}');
    }
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
  }

  Future<void> _fetchItems() async {
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
        setState(() {
          _tasks.clear();
          for (var item in items) {
            _tasks.add(Task(
                id: item['id'],
                title: item['title'],
                description: item['description'],
                isDone: item['is_done']));
          }
          _sortTasks();
        });
      } else {
        print('Failed to fetch items: ${response.body}');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void _sortTasks() {
    setState(() {
      _tasks.sort((a, b) {
        if (a.isDone && !b.isDone) return 1;
        if (!a.isDone && b.isDone) return -1;
        return b.id.compareTo(a.id); // Assuming higher IDs are newer tasks
      });
    });
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
              leading: Text('${index + 1}'), // Display the item number
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
        'is_done': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['is_done'],
    );
  }
}
