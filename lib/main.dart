import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils.dart';
import 'welcome.dart';
import 'todo_screen.dart';
import 'database_helper.dart';
import 'sqflite_database_helper.dart';
import 'web_database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    DatabaseHelper.databaseHelper = WebDatabaseHelper();
  } else {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    DatabaseHelper.databaseHelper = SqfliteDatabaseHelper();
  }

  runApp(MyApp());
}

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
