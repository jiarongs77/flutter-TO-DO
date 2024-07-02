import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_notifier.dart';
import 'database_helper.dart';
import 'utils.dart';
import 'task.dart';
import 'welcome.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.databaseHelper;

  @override
  void initState() {
    super.initState();
    _fetchAndCacheItems();
  }

  Future<void> _fetchAndCacheItems() async {
    try {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/v1/items/?skip=0&limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authNotifier.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> items = jsonDecode(response.body);
        List<Task> tasks = items.map((item) => Task.fromJson(item)).toList();
        await _dbHelper.insertTasks(tasks); // Save to local database
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
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    if (title.isNotEmpty && description.isNotEmpty) {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/v1/items/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authNotifier.accessToken}',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'description': description,
          'is_done': false,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        Task newTask = Task(
          id: responseBody['id'],
          title: title,
          description: description,
          isDone: false,
        );
        await _dbHelper.insertTask(newTask);
        _fetchItemsFromLocal();
      } else {
        print('Failed to create item: ${response.body}');
      }
    }
  }

  Future<void> _toggleDone(int id) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    var task = _tasks.firstWhere((t) => t.id == id);
    var response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/v1/items/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authNotifier.accessToken}',
      },
      body: jsonEncode(<String, dynamic>{
        'title': task.title,
        'description': task.description,
        'is_done': !task.isDone,
      }),
    );
    if (response.statusCode == 200) {
      task.isDone = !task.isDone;
      await _dbHelper.updateTask(task);
      _fetchItemsFromLocal();
    } else {
      print('Failed to update item: ${response.body}');
    }
  }

  Future<void> _removeTask(int id) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    var response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/v1/items/$id'),
      headers: {
        'Authorization': 'Bearer ${authNotifier.accessToken}',
      },
    );
    if (response.statusCode == 200) {
      await _dbHelper.deleteTask(id);
      _fetchItemsFromLocal();
    } else {
      print('Failed to delete item: ${response.body}');
    }
  }

  Future<void> _updateTask(int id, String title, String description, bool isDone) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    var response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/v1/items/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authNotifier.accessToken}',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'description': description,
        'is_done': isDone,
      }),
    );
    if (response.statusCode == 200) {
      var task = Task(id: id, title: title, description: description, isDone: isDone);
      await _dbHelper.updateTask(task);
      _fetchItemsFromLocal();
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

  void _sortTasks() {
    setState(() {
      _tasks.sort((a, b) {
        if (a.isDone && !b.isDone) return 1;
        if (!a.isDone && b.isDone) return -1;
        return b.id.compareTo(a.id); // Higher IDs are newer tasks, so this reverses the order
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
    final authNotifier = Provider.of<AuthNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            authNotifier.logoutUser().then((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            });
          },
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
                '${index + 1}',
                style: TextStyle(fontSize: 15),
              ),
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    iconSize: 18,
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
      floatingActionButton: authNotifier.isAuthenticated
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
