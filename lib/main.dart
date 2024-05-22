import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      home: TodoScreen(),
    );
  }
}

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
    _restoreLoginStatus().then((_) {
      if (_isLoggedIn) {
        _fetchItems();
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
      debugPrint("stating add items!");
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
      debugPrint("response!!!!!!$response");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          _tasks.add(Task(id: responseBody['id'], title: title, description: description));
        });
      } else {
        print('Failed to create item: ${response.body}');
      }
    }
  }

  void _toggleDone(int id) async {
    var task = _tasks.firstWhere((t) => t.id == id);
    debugPrint("tasks${task.isDone}, ${task.id}");
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
    debugPrint("response button${response.statusCode}");
    if (response.statusCode == 200) {
      setState(() {
        task.isDone = !task.isDone;
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

  void _handleLoginSuccess() {
    debugPrint("login success!");
    _restoreLoginStatus().then((_) {
      setState(() {
        _fetchItems();
      });
    });
  }

  void _handleLogoutSuccess() {
    debugPrint("logout success!");
    _isLoggedIn = false;
    _tasks.clear();
    setState(() {});
  }

  void _showMenuSelection(String value) {
    switch (value) {
      case 'Register':
        if (!_isLoggedIn) {
          showRegisterDialog(context);
        }
        break;
      case 'Login':
        if (!_isLoggedIn) {
          showLoginDialog(context, _handleLoginSuccess);
        }
        break;
      case 'Logout':
        logout(context, _handleLogoutSuccess);
        break;
      default:
        print('Unknown option: $value');
    }
  }

  Future<void> _fetchItems() async {
    try {
      debugPrint("start!!");
      debugPrint("print token:$_accessToken");
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/v1/items/?skip=0&limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      debugPrint("response fetch!!!!!!$response");
      if (response.statusCode == 200) {
        List<dynamic> items = jsonDecode(response.body);
        setState(() {
          _tasks.clear();
          for (var item in items) {
            debugPrint("response items!!!!!!$item");
            _tasks.add(Task(id: item['id'], title: item['title'], description: item['description'], isDone: item['is_done']));
          }
        });
      } else {
        print('Failed to fetch items: ${response.body}');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialogGeneric(
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
        leading: PopupMenuButton<String>(
          onSelected: _showMenuSelection,
          itemBuilder: (BuildContext context) {
            return _isLoggedIn
                ? <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text('Logout'),
                    ),
                  ]
                : <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Register',
                      child: Text('Register'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Login',
                      child: Text('Login'),
                    ),
                  ];
          },
          icon: Icon(Icons.person),
        ),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Text('${index + 1}'), // Display the item number
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: IconButton(
              icon: Icon(
                task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
              ),
              onPressed: () => _toggleDone(task.id),
            ),
            onLongPress: () => _removeTask(task.id),
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
