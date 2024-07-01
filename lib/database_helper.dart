import 'task.dart';

abstract class DatabaseHelper {
  static late DatabaseHelper _databaseHelper;
  
  static set databaseHelper(DatabaseHelper helper) {
    _databaseHelper = helper;
  }
  
  static DatabaseHelper get databaseHelper => _databaseHelper;

  Future<List<Task>> fetchTasks();
  Future<void> insertTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<void> insertTasks(List<Task> tasks);
}
