import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _addTask(String title) async {
    if (title.isNotEmpty) {
      var response = await http.post(
        Uri.parse('http://localhost:8000/items/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'is_done': false,
        }),
      );
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          _tasks.add(Task(id: responseBody['item_id'], title: title));
        });
      }
    }
  }

  void _toggleDone(int id) async {
    var task = _tasks.firstWhere((t) => t.id == id);
    var response = await http.put(
      Uri.parse('http://localhost:8000/items/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'title': task.title,
        'is_done': !task.isDone,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        task.isDone = !task.isDone;
      });
    }
  }

  void _removeTask(int id) async {
    var response = await http.delete(Uri.parse('http://localhost:8000/items/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _tasks.removeWhere((t) => t.id == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                var task = _tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(task.id),
                  ),
                  onTap: () => _toggleDone(task.id),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) {
                _addTask(value);
                _controller.clear();
              },
              decoration: InputDecoration(
                labelText: 'Add a Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  int id;
  String title;
  bool isDone;

  Task({required this.id, required this.title, this.isDone = false});
}
