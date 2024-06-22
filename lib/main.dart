import 'package:flutter/material.dart';
import 'utils.dart';
import 'welcome.dart';
import 'todo_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      home: FutureBuilder(
        future: Utils.checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator while checking login status
          } else if (snapshot.data == true) {
            return TodoScreen(); // Navigate to TODO Screen if logged in
          } else {
            return WelcomePage(); // Navigate to Welcome Page if not logged in
          }
        },
      ),
    );
  }
}
