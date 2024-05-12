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

  void _showMenuSelection(String value) {
    switch (value) {
      case 'Register':
        _showRegisterDialog();
        break;
      case 'Login':
        _showLoginDialog();  // This function now prompts for user credentials
        break;
      default:
        print('Unknown option: $value');
    }
  }

  Future<void> _registerUser(String email, String password, String fullName) async {
    var url = Uri.parse('http://127.0.0.1:8000/api/v1/users/register');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );
    if (response.statusCode == 200) {
      print('User registered successfully');
      // Optionally navigate or provide feedback
    } else {
      print('Failed to register user: ${response.body}');
      // Optionally handle errors or provide feedback
    }
  }

Future<void> _loginUser(String email, String password) async {
  var url = Uri.parse('http://127.0.0.1:8000/api/v1/login/access-token');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&grant_type=password'
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Successful"),
          content: Text("Welcome back!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    print('Access Token: ${responseBody['access_token']}');
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Failed"),
          content: Text("Incorrect email or password."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void _showDialog({
  required String title,
  required List<TextField> fields,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: EdgeInsets.all(0),
        title: AppBar(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          automaticallyImplyLeading: false,
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          elevation: 0,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: Text(title),
          ),
        ],
      );
    },
  );
}

void _showRegisterDialog() {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  _showDialog(
    title: 'Register',
    fields: [
      TextField(
        controller: emailController,
        decoration: InputDecoration(labelText: 'Email'),
      ),
      TextField(
        controller: passwordController,
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
      ),
      TextField(
        controller: fullNameController,
        decoration: InputDecoration(labelText: 'Full Name'),
      ),
    ],
    onConfirm: () => _registerUser(
      emailController.text,
      passwordController.text,
      fullNameController.text,
    ),
  );
}

void _showLoginDialog() {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  _showDialog(
    title: 'Login',
    fields: [
      TextField(
        controller: emailController,
        decoration: InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
      ),
      TextField(
        controller: passwordController,
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
      ),
    ],
    onConfirm: () => _loginUser(
      emailController.text,
      passwordController.text,
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
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Register',
              child: Text('Register'),
            ),
            const PopupMenuItem<String>(
              value: 'Login',
              child: Text('Login'),
            ),
          ],
          icon: Icon(Icons.person),
        ),
      ),
      body: Column(
        // Existing body widgets
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
