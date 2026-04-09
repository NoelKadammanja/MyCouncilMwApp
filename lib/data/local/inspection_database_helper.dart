import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InspectionDatabaseHelper {
  static final InspectionDatabaseHelper _instance = InspectionDatabaseHelper._internal();
  static Database? _database;

  InspectionDatabaseHelper._internal();

  factory InspectionDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inspection.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table for storing pending inspection results
    await db.execute('''
      CREATE TABLE pending_inspections (
        id TEXT PRIMARY KEY,
        application_id TEXT NOT NULL,
        business_name TEXT NOT NULL,
        results TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        attempts INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending'
      )
    ''');

    // Table for storing offline assignments
    await db.execute('''
      CREATE TABLE offline_assignments (
        id TEXT PRIMARY KEY,
        assignment_data TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Index for faster queries
    await db.execute('CREATE INDEX idx_pending_status ON pending_inspections(status)');
    await db.execute('CREATE INDEX idx_offline_synced ON offline_assignments(synced)');
  }

  // Save pending inspection
  Future<void> savePendingInspection({
    required String id,
    required String applicationId,
    required String businessName,
    required String results,
  }) async {
    final db = await database;
    await db.insert(
      'pending_inspections',
      {
        'id': id,
        'application_id': applicationId,
        'business_name': businessName,
        'results': results,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'attempts': 0,
        'status': 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all pending inspections
  Future<List<Map<String, dynamic>>> getPendingInspections() async {
    final db = await database;
    return await db.query(
      'pending_inspections',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  // Update pending inspection status
  Future<void> updatePendingInspectionStatus(String id, String status, {int? attempts}) async {
    final db = await database;
    final updates = <String, dynamic>{'status': status};
    if (attempts != null) {
      updates['attempts'] = attempts;
    }
    await db.update(
      'pending_inspections',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete pending inspection
  Future<void> deletePendingInspection(String id) async {
    final db = await database;
    await db.delete(
      'pending_inspections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Save offline assignments
  Future<void> saveOfflineAssignments(List<dynamic> assignments) async {
    final db = await database;
    await db.delete('offline_assignments'); // Clear old data
    for (var assignment in assignments) {
      await db.insert(
        'offline_assignments',
        {
          'id': assignment['id'],
          'assignment_data': jsonEncode(assignment),
          'synced': 0,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Get offline assignments
  Future<List<Map<String, dynamic>>> getOfflineAssignments() async {
    final db = await database;
    return await db.query('offline_assignments');
  }

  // Clear all data
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('pending_inspections');
    await db.delete('offline_assignments');
  }
}