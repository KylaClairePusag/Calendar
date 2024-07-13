// database_helper.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'events.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            date TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertEvent(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('events', row);
  }

  Future<List<Map<String, dynamic>>> queryAllEvents() async {
    final db = await database;
    return await db.query('events');
  }

  Future<int> updateEvent(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update('events', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
