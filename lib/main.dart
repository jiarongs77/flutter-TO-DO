import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils.dart';
import 'welcome.dart';
import 'todo_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for different platforms
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
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

// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'utils.dart';
// import 'welcome.dart';
// import 'todo_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (!kIsWeb) {
//     // Initialize sqflite for mobile and desktop platforms
//     if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//       sqfliteFfiInit();
//       databaseFactory = databaseFactoryFfi;
//     }
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TODO App',
//       home: FutureBuilder(
//         future: Utils.checkLoginStatus(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator()); // Show loading indicator while checking login status
//           } else if (snapshot.data == true) {
//             return TodoScreen(); // Navigate to TODO Screen if logged in
//           } else {
//             return WelcomePage(); // Navigate to Welcome Page if not logged in
//           }
//         },
//       ),
//     );
//   }
// }
