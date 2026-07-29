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
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    await _createCalendarTables(db);
    await _createProfitTables(db);
    await _createGuideTables(db);
    await _createMarketTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCalendarTables(db);
    }
    if (oldVersion < 3) {
      await _createProfitTables(db);
    }
    if (oldVersion < 4) {
      await _createGuideTables(db);
    }
    if (oldVersion < 5) {
      await _createMarketTables(db);
    }
  }

  Future<void> _createMarketTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS market_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        market_name TEXT NOT NULL,
        crop_id INTEGER NOT NULL,
        price REAL NOT NULL,
        last_week_price REAL,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _createGuideTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pesticides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trade_name TEXT NOT NULL,
        active_ingredient TEXT,
        targets TEXT,
        crops TEXT,
        dosage TEXT,
        usage_method TEXT,
        safety_period TEXT,
        warnings TEXT,
        crop_ids TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fertilizers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trade_name TEXT NOT NULL,
        fertilizer_type TEXT,
        npk TEXT,
        target_crops TEXT,
        dosage TEXT,
        application_time TEXT,
        application_method TEXT,
        crop_ids TEXT
      )
    ''');
  }

  Future<void> _createProfitTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS profit_calculations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        crop_id INTEGER NOT NULL,
        crop_name TEXT NOT NULL,
        feddans REAL NOT NULL,
        seed_cost REAL,
        fertilizer_cost REAL,
        irrigation_cost REAL,
        labor_cost REAL,
        pesticide_cost REAL,
        total_cost REAL,
        expected_production REAL,
        price_per_kg REAL,
        total_revenue REAL,
        net_profit REAL,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createCalendarTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS calendar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        crop_id INTEGER NOT NULL,
        state TEXT NOT NULL,
        planting_start TEXT,
        planting_end TEXT,
        first_irrigation_days INTEGER DEFAULT 7,
        first_fertilizer_days INTEGER DEFAULT 21,
        second_fertilizer_days INTEGER DEFAULT 45,
        harvest_days INTEGER DEFAULT 105
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS calendar_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        crop_id INTEGER NOT NULL,
        state TEXT NOT NULL,
        alert_type TEXT NOT NULL,
        days_offset INTEGER DEFAULT 0,
        enabled INTEGER DEFAULT 1,
        task_id INTEGER,
        created_at TEXT
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
