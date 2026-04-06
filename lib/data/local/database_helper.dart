import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'naml_app.db';

  // ✅ Bump this every time you add/change columns.
  // Current bump: 1 → 2 adds role, council_*, department_*, last_refresh
  static const int _dbVersion = 2;

  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─── Full schema (version 2) ──────────────────────────────────────────────
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id               TEXT,
        name             TEXT,
        email            TEXT,
        client_id        TEXT,
        nat_number       TEXT,
        status           TEXT,
        email_verified_at TEXT,
        created_at       TEXT,
        updated_at       TEXT,
        token            TEXT,
        role             TEXT,
        council_id       TEXT,
        council_name     TEXT,
        council_code     TEXT,
        department_id    TEXT,
        department_name  TEXT,
        last_refresh     INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE money_market (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id     TEXT,
        type          TEXT,
        start_date    TEXT,
        maturity_date TEXT,
        invested_amount REAL,
        rate          REAL,
        accrued_interest REAL,
        current_value REAL,
        tenure_days   INTEGER,
        source_pdf    TEXT,
        last_refresh  INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE government_securities (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id       TEXT,
        instrument_type TEXT,
        start_date      TEXT,
        maturity_date   TEXT,
        invested_amount REAL,
        rate            REAL,
        accrued_interest REAL,
        current_value   REAL,
        source_pdf      TEXT,
        last_refresh    INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE shares (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id        TEXT,
        counter          TEXT,
        number_of_shares INTEGER,
        purchase_price   REAL,
        purchase_cost    REAL,
        current_price    REAL,
        gain_loss        REAL,
        current_value    REAL,
        last_refresh     INTEGER
      )
    ''');
  }

  // ─── Migrations ───────────────────────────────────────────────────────────
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // v1 → v2: add inspection/council columns to user table
    if (oldVersion < 2) {
      // Use try/catch per column so a partial upgrade doesn't block the rest
      final v2Columns = {
        'role': 'TEXT',
        'council_id': 'TEXT',
        'council_name': 'TEXT',
        'council_code': 'TEXT',
        'department_id': 'TEXT',
        'department_name': 'TEXT',
        'last_refresh': 'INTEGER',
      };

      for (final entry in v2Columns.entries) {
        try {
          await db.execute(
              'ALTER TABLE user ADD COLUMN ${entry.key} ${entry.value}');
        } catch (_) {
          // Column may already exist in some intermediate builds — safe to skip
        }
      }
    }

    // Add future migrations here:
    // if (oldVersion < 3) { ... }
  }
}