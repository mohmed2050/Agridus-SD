import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'agridus.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_en TEXT,
        icon TEXT,
        pests TEXT,
        diseases TEXT,
        season TEXT,
        soil TEXT,
        ph_level TEXT,
        land_prep TEXT,
        planting_method TEXT,
        irrigation TEXT,
        fertilization TEXT,
        harvest TEXT,
        profitability TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        alert_time TEXT,
        recurrence TEXT DEFAULT 'once',
        is_completed INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        source TEXT,
        date TEXT,
        summary TEXT,
        url TEXT,
        cached_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {required String where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.update(table, data,
        where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table,
      {required String where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
