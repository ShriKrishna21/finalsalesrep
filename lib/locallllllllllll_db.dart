import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Agent Screen DB Helper for assigned agency data For Ofline Access Created By SriHari
class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'salesrep.db');
    print('DB Path: $path'); // Log for debug
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE assigned_agency (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agency_id TEXT UNIQUE,
            location_name TEXT,
            code TEXT,
            unit TEXT,
            phone TEXT,
            timestamp INTEGER
          )
        ''');
        print('Table created');
      },
    );
  }

  Future<void> saveAssignedAgency({
    required String agencyId,
    required String locationName,
    required String code,
    required String unit,
    String? phone,
  }) async {
    final database = await db;
    try {
      await database.delete('assigned_agency');
      await database.insert('assigned_agency', {
        'agency_id': agencyId,
        'location_name': locationName,
        'code': code,
        'unit': unit,
        'phone': phone,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('Agency saved: $locationName');
    } catch (e) {
      print('Save error: $e');
    }
  }

  Future<Map<String, dynamic>?> getAssignedAgency() async {
    final database = await db;
    try {
      final List<Map<String, dynamic>> rows =
          await database.query('assigned_agency', limit: 1);
      print('Loaded agency: ${rows.firstOrNull}'); // Log result
      return rows.isEmpty ? null : rows.first;
    } catch (e) {
      print('Load error: $e');
      return null;
    }
  }

  Future<void> clearAssignedAgency() async {
    final database = await db;
    await database.delete('assigned_agency');
  }
}
