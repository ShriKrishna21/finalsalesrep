// lib/offline/dbhelper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // This works 100% on all Android/iOS devices
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_agents.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_agents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        aadhar_number TEXT,
        pan_number TEXT,
        state TEXT,
        phone TEXT NOT NULL,
        aadhar_base64 TEXT,
        pan_base64 TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertAgent(Map<String, dynamic> agent) async {
    final db = await database;
    return await db.insert('offline_agents', agent);
  }

  Future<List<Map<String, dynamic>>> getAllPending() async {
    final db = await database;
    return await db.query('offline_agents', orderBy: 'created_at ASC');
  }

  Future<int> deleteAgent(int id) async {
    final db = await database;
    return await db.delete('offline_agents', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('offline_agents');
  }
}