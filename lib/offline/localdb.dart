// file: local_db.dart

import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDb {
  static final LocalDb _instance = LocalDb._internal();
  factory LocalDb() => _instance;
  LocalDb._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'customer_forms.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customer_forms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            form_data TEXT,
            status TEXT,  -- "pending", "sent", etc
            updated_at INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertForm(Map<String, dynamic> form) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.insert(
      'customer_forms',
      {
        'form_data': jsonEncode(form),
        'status': 'pending',
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateForm(int id, Map<String, dynamic> form) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      'customer_forms',
      {
        'form_data': jsonEncode(form),
        'status': 'pending',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingForms() async {
    final db = await database;
    List<Map<String, dynamic>> list = await db.query(
      'customer_forms',
      where: 'status = ?',
      whereArgs: ['pending'],
    );
    return list;
  }

  Future<int> markFormSent(int id) async {
    final db = await database;
    return await db.update(
      'customer_forms',
      {
        'status': 'sent',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
