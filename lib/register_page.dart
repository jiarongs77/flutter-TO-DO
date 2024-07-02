import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils.dart';
import 'welcome.dart';  // Import WelcomePage

class RegisterPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

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
      return 'error';
    } else {
      print('Failed to register user: ${response.body}');
      return 'error';
    }
  }

  void onRegister(BuildContext context) {
    String email = emailController.text;
    String password = passwordController.text;
    String fullName = fullNameController.text;

    if (!Utils.isValidEmail(email)) {
      Utils.showErrorMessage(context, 'Email or password invalid');
      return;
    } else if (password.length < 4 || password.length > 10) {
      Utils.showErrorMessage(context, 'Email or password invalid');
      return;
    } else {
      registerUser(email, password, fullName).then((result) {
        if (result == 'success') {
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dialog from being dismissed by user
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                title: Text("Register Successful"),
                content: Text("User registered successfully"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (result == 'exists') {
          Utils.showErrorMessage(context, 'The email address already exists');
        } else {
          Utils.showErrorMessage(context, 'Failed to register user');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 400), // Limit the width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter a valid email address',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '4-10 characters',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => onRegister(context),
                  child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), // Width and height of the button
                    backgroundColor: Colors.white, // Button background color
                    side: BorderSide(color: Colors.deepPurple), // Border color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
