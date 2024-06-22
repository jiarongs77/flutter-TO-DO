import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'todo_screen.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'DoneDeal',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, 
              ),
            ),
            Text(
              'Your everyday to-do list manager',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.deepPurple, 
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30), // Space between the logo and buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Login', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), // Width and height of the button
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Register', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), // Width and height of the button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
