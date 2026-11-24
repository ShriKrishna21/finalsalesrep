
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PromotionDatabase {
  PromotionDatabase._();

  static final PromotionDatabase instance =
      PromotionDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'promotion_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE agency_master (
            id INTEGER PRIMARY KEY,
            name TEXT,
            code TEXT,
            location_name TEXT,
            phone TEXT,
            unit_name TEXT
          )
        ''');
      },
    );
  }
}
