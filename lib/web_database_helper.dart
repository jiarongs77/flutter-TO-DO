import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'task.dart';

class WebDatabaseHelper implements DatabaseHelper {
  static final WebDatabaseHelper _instance = WebDatabaseHelper._internal();
  factory WebDatabaseHelper() => _instance;

  WebDatabaseHelper._internal();

  @override
  Future<List<Task>> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? taskStrings = prefs.getStringList('tasks');
    if (taskStrings != null) {
      return taskStrings.map((taskString) => Task.fromJson(jsonDecode(taskString))).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> insertTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList('tasks') ?? [];
    taskStrings.add(jsonEncode(task.toJson()));
    await prefs.setStringList('tasks', taskStrings);
  }

  @override
  Future<void> updateTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList('tasks') ?? [];
    final int index = taskStrings.indexWhere((taskString) => Task.fromJson(jsonDecode(taskString)).id == task.id);
    if (index != -1) {
      taskStrings[index] = jsonEncode(task.toJson());
      await prefs.setStringList('tasks', taskStrings);
      print('Task updated in SharedPreferences: ${task.toJson()}');
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList('tasks') ?? [];
    taskStrings.removeWhere((taskString) => Task.fromJson(jsonDecode(taskString)).id == id);
    await prefs.setStringList('tasks', taskStrings);
  }

  @override
  Future<void> insertTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskStrings);
  }
}
