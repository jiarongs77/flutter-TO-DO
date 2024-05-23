import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void showDialogGeneric({
  required BuildContext context,
  required String title,
  required List<Widget> fields,
  required VoidCallback onConfirm, 
  String? errorMessage,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        contentPadding: EdgeInsets.all(16.0),
        content: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                  ...fields,
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onConfirm,
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

void showRegisterDialog(BuildContext context) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  void onConfirm() {
    String email = emailController.text;
    String password = passwordController.text;
    String fullName = fullNameController.text;

    if (!_isValidEmail(email)) {
      _showErrorMessage(context, 'Email or password invalid');
      return;
    } else if (password.length < 4 || password.length > 10) {
      _showErrorMessage(context, 'Email or password invalid');
      return;
    } else {
      registerUser(email, password, fullName).then((result) {
        if (result == 'success') {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                title: Text("Register Successful"),
                content: Text("User registered successfully"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          _showErrorMessage(context, 'The email address already exists');
        } 
      });
    }
  }

  showDialogGeneric(
    context: context,
    title: 'Register',
    fields: [
      TextField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Enter a valid email address',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      TextField(
        controller: passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: '4-10 characters',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        obscureText: true,
      ),
      TextField(
        controller: fullNameController,
        decoration: InputDecoration(labelText: 'Full Name'),
      ),
    ],
    onConfirm: onConfirm,
  );
}

void _showErrorMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        title: Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

bool _isValidEmail(String email) {
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return regex.hasMatch(email);
}

void showLoginDialog(BuildContext context, VoidCallback onLoginSuccess) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  void onConfirm() {
    loginUser(emailController.text, passwordController.text, context, onLoginSuccess)
        .then((success) {
      if (success) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              title: Text("Login Successful"),
              content: Text("Welcome back!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        errorMessage = 'Invalid email or password';
        Navigator.of(context).pop();
        _showErrorMessage(context, errorMessage!);
      }
    });
  }

  showDialogGeneric(
    context: context,
    title: 'Login',
    fields: [
      TextField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Please enter your email address',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      TextField(
        controller: passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Please enter your password',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        obscureText: true,
      ),
    ],
    onConfirm: onConfirm,
    errorMessage: errorMessage,
  );
}

void logout(BuildContext context, VoidCallback onLogoutSuccess) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  onLogoutSuccess();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        title: Text("Logout Successful"),
        content: Text("You have been logged out."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<bool> loginUser(String email, String password, BuildContext context, VoidCallback onLoginSuccess) async {
  var url = Uri.parse('http://127.0.0.1:8000/api/v1/login/access-token');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&grant_type=password',
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', responseBody['access_token']);
    onLoginSuccess();
    return true;
  } else {
    return false;
  }
}

Future<String> registerUser(String email, String password, String fullName) async {
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
    return 'success';
  } else if (response.statusCode == 409) {
    print('Email already exists');
    return 'exists';
  } else {
    print('Failed to register user: ${response.body}');
    return 'error';
  }
}