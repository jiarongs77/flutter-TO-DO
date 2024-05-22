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
      // _fetchItems();  // Fetch items after logging in
      onLoginSuccess();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login Successful"),
            content: Text("Welcome back!"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
