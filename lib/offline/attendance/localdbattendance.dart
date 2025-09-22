import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

enum PendingActionType { startWork, stopWork }

class LocalDbattendance {
  LocalDbattendance._();
  static final LocalDbattendance instance = LocalDbattendance._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'salesrep_offline.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE pending_actions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,          -- startWork | stopWork
            selfie TEXT,                   -- base64
            created_at TEXT NOT NULL,      -- ISO8601
            status TEXT NOT NULL DEFAULT 'pending'  -- pending | synced | failed
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> enqueueAction({
    required PendingActionType type,
    String? selfieBase64,
    DateTime? createdAt,
  }) async {
    final d = await db;
    return d.insert('pending_actions', {
      'action': type == PendingActionType.startWork ? 'startWork' : 'stopWork',
      'selfie': selfieBase64,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> pendingActions() async {
    final d = await db;
    return d.query(
      'pending_actions',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id ASC',
    );
  }

  /// ✅ Used by your read-only list screen
  Future<List<Map<String, dynamic>>> getAllActions() async {
    final d = await db;
    return d.query('pending_actions', orderBy: 'id DESC');
  }

  Future<void> markAsSynced(int id) async {
    final d = await db;
    await d.update('pending_actions', {'status': 'synced'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAsFailed(int id) async {
    final d = await db;
    await d.update('pending_actions', {'status': 'failed'}, where: 'id = ?', whereArgs: [id]);
  }
}
