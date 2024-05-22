import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



void showDialogGeneric({
  required BuildContext context,
  required String title,
  required List<TextField> fields,
  required VoidCallback onConfirm,
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
                    padding: const EdgeInsets.only(right: 24.0), // Add padding to prevent overlap
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18), // Adjust font size here
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
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
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

  showDialogGeneric(
    context: context,
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
    onConfirm: () => registerUser(
      emailController.text,
      passwordController.text,
      fullNameController.text,
    ),
  );
}

void showLoginDialog(BuildContext context, VoidCallback onLoginSuccess) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  showDialogGeneric(
    context: context,
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
    onConfirm: () => loginUser(
      emailController.text,
      passwordController.text,
      context,
      onLoginSuccess,
    ),
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

Future<void> loginUser(String email, String password, BuildContext context, VoidCallback onLoginSuccess) async {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', responseBody['access_token']);
    onLoginSuccess();
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
      }
    );
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text("Login Failed"),
          content: Text("Incorrect email or password."),
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
}

Future<void> registerUser(String email, String password, String fullName) async {
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
