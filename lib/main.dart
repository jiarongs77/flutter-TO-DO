import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'welcome.dart';
import 'todo_screen.dart';
import 'database_helper.dart';
import 'sqflite_database_helper.dart';
import 'web_database_helper.dart';
import 'package:provider/provider.dart';
import 'auth_notifier.dart';

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

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthNotifier(),
      child: MyApp(),
    ),
  );
  print('RunApp called...');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building MyApp...');
    return MaterialApp(
      title: 'TODO App',
      home: Consumer<AuthNotifier>(
        builder: (context, authNotifier, child) {
          print('Consumer builder called...');
          if (authNotifier.isLoading) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return authNotifier.isAuthenticated ? TodoScreen() : WelcomePage();
          }
        },
      ),
    );
  }
}
