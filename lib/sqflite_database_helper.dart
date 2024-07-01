import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'task.dart';

class SqfliteDatabaseHelper implements DatabaseHelper {
  static final SqfliteDatabaseHelper _instance = SqfliteDatabaseHelper._internal();
  factory SqfliteDatabaseHelper() => _instance;
  static Database? _database;

  SqfliteDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    print('Initializing database at path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    print('Creating tasks table');
    await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            is_done INTEGER NOT NULL
          )
          ''');
  }

  @override
  Future<List<Task>> fetchTasks() async {
    try {
      print('Fetching tasks from database');
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: "id DESC");
      print('Fetched ${maps.length} tasks from database');

      if (maps.isNotEmpty) {
        return List.generate(maps.length, (i) {
          print('Task fetched: ${maps[i]}');
          return Task.fromJson(maps[i]);
        });
      } else {
        print('No tasks found in database');
        return [];
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  @override
  Future<void> insertTask(Task task) async {
    print('Inserting task into database: $task');
    Database db = await database;
    await db.insert('tasks', task.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTask(Task task) async {
    print('Updating task in database: $task');
    Database db = await database;
    await db.update('tasks', task.toJson(), where: 'id = ?', whereArgs: [task.id]);
  }

  @override
  Future<void> deleteTask(int id) async {
    print('Deleting task from database with id: $id');
    Database db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> insertTasks(List<Task> tasks) async {
    Database db = await database;
    Batch batch = db.batch();
    for (var task in tasks) {
      batch.insert('tasks', task.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
    print('Inserted tasks into database');
  }
}
