import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_notifier.dart';
import 'utils.dart';
import 'todo_screen.dart';  // Import the TodoScreen

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onConfirm(BuildContext context) {
    String email = emailController.text;
    String password = passwordController.text;

    if (!Utils.isValidEmail(email) || password.isEmpty) {
      Utils.showErrorMessage(context, 'Invalid email or password');
      return;
    } else {
      Provider.of<AuthNotifier>(context, listen: false)
          .loginUser(email, password)
          .then((success) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TodoScreen()),  // Navigate to TodoScreen
          );
        } else {
          Utils.showErrorMessage(context, 'Invalid email or password');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                    hintText: 'Please enter your email address',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Please enter your password',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => onConfirm(context),
                  child: Text('Login', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), // Width and height of the button
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
