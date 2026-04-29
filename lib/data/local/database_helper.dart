import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String dbName = 'local_govt_mw.db';
  static const int dbVersion = 8; // v8: store currentStageCode in workflow_stage

  // Table names
  static const String tableUsers = 'users';
  static const String tableAssignments = 'assignments';
  static const String tableChecklistItems = 'checklist_items';
  static const String tablePendingSubmissions = 'pending_submissions';
  static const String tableChecklistCache = 'checklist_cache';
  static const String tableNotifications = 'notifications';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table - persists login session
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        token TEXT NOT NULL,
        full_name TEXT,
        role TEXT,
        council_id TEXT,
        council_name TEXT,
        council_code TEXT,
        department TEXT,
        portfolio TEXT,
        raw_json TEXT,
        last_refresh INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Assignments table - cached from API
    await db.execute('''
      CREATE TABLE $tableAssignments (
        id TEXT PRIMARY KEY,
        business_id TEXT,
        business_name TEXT NOT NULL,
        category_name TEXT,
        council_id TEXT,
        council_name TEXT,
        created_at TEXT,
        expiry_date TEXT,
        final_approved_fee REAL,
        issued_date TEXT,
        owner_name TEXT,
        owner_type TEXT,
        reference_number TEXT,
        status TEXT NOT NULL,
        submitted_by_name TEXT,
        submitted_by_user_id TEXT,
        type TEXT,
        license_type_id TEXT,
        raw_json TEXT NOT NULL,
        synced_at INTEGER NOT NULL
      )
    ''');

    // Checklist items cache - so inspectors can work offline
    await db.execute('''
      CREATE TABLE $tableChecklistCache (
        license_type_id TEXT NOT NULL,
        license_type_name TEXT,
        raw_json TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        PRIMARY KEY (license_type_id)
      )
    ''');

    // Pending submissions - inspection results waiting to be synced
    await db.execute('''
      CREATE TABLE $tablePendingSubmissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        application_id TEXT NOT NULL,
        business_name TEXT NOT NULL,
        results_json TEXT NOT NULL,
        evidence_json TEXT,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_attempt INTEGER,
        status TEXT DEFAULT 'pending',
        error_message TEXT
      )
    ''');

    // Notifications table — workflow_stage stores currentStageCode (e.g. SUBMIT_INSPECTION)
    await db.execute('''
      CREATE TABLE $tableNotifications (
        id TEXT PRIMARY KEY,
        assignment_id TEXT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        business_name TEXT,
        reference_number TEXT,
        status TEXT,
        workflow_stage TEXT,
        created_at INTEGER NOT NULL,
        is_read INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tablePendingSubmissions ADD COLUMN error_message TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableChecklistCache (
          license_type_id TEXT NOT NULL,
          license_type_name TEXT,
          raw_json TEXT NOT NULL,
          cached_at INTEGER NOT NULL,
          PRIMARY KEY (license_type_id)
        )
      ''');
    }
    if (oldVersion < 4) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info($tableUsers)');
        final hasCouncilCode =
        columns.any((col) => col['name'] == 'council_code');
        if (!hasCouncilCode) {
          await db.execute(
            'ALTER TABLE $tableUsers ADD COLUMN council_code TEXT',
          );
          debugPrint('DB: Added council_code column to users table');
        }
      } catch (e) {
        debugPrint('DB: Error adding council_code column: $e');
      }
    }
    if (oldVersion < 5) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableNotifications (
            id TEXT PRIMARY KEY,
            assignment_id TEXT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            business_name TEXT,
            reference_number TEXT,
            status TEXT,
            created_at INTEGER NOT NULL,
            is_read INTEGER DEFAULT 0
          )
        ''');
        debugPrint('DB: Created notifications table');
      } catch (e) {
        debugPrint('DB: Error creating notifications table: $e');
      }
    }
    if (oldVersion < 6) {
      try {
        final columns =
        await db.rawQuery('PRAGMA table_info($tableNotifications)');
        final hasWorkflowStage =
        columns.any((col) => col['name'] == 'workflow_stage');
        if (!hasWorkflowStage) {
          await db.execute(
            'ALTER TABLE $tableNotifications ADD COLUMN workflow_stage TEXT',
          );
          debugPrint(
              'DB: Added workflow_stage column to notifications table');
        }
      } catch (e) {
        debugPrint('DB: Error adding workflow_stage column: $e');
      }
    }
    if (oldVersion < 7) {
      try {
        final columns = await db
            .rawQuery('PRAGMA table_info($tablePendingSubmissions)');
        final hasEvidenceJson =
        columns.any((col) => col['name'] == 'evidence_json');
        if (!hasEvidenceJson) {
          await db.execute(
            'ALTER TABLE $tablePendingSubmissions ADD COLUMN evidence_json TEXT',
          );
          debugPrint(
              'DB: Added evidence_json column to pending_submissions table');
        }
      } catch (e) {
        debugPrint('DB: Error adding evidence_json column: $e');
      }
    }
    if (oldVersion < 8) {
      try {
        // Clear all notifications so they are re-created fresh with
        // currentStageCode stored in workflow_stage instead of currentStageName.
        // This ensures the badge count logic (== 'SUBMIT_INSPECTION') works correctly.
        await db.delete(tableNotifications);
        debugPrint(
            'DB: Cleared notifications for stage-code migration (v8)');
      } catch (e) {
        debugPrint(
            'DB: Error clearing notifications on v8 upgrade: $e');
      }
    }
  }

  // ============================================================
  // USER SESSION METHODS
  // ============================================================

  Future<void> saveUser(Map<String, dynamic> loginData) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    String email = loginData['email']?.toString() ?? '';
    String token = loginData['token']?.toString() ?? '';
    String fullName = loginData['fullName']?.toString() ??
        loginData['full_name']?.toString() ??
        '';
    String role = loginData['role']?.toString() ?? '';

    String councilId = '';
    String councilName = '';
    String councilCode = '';

    if (loginData['council'] != null && loginData['council'] is Map) {
      final council = loginData['council'] as Map;
      councilId = council['id']?.toString() ?? '';
      councilName = council['name']?.toString() ?? '';
      councilCode = council['code']?.toString() ?? '';
      debugPrint(
          'DB: Extracted council from nested object: id=$councilId, name=$councilName, code=$councilCode');
    } else {
      councilId = loginData['councilId']?.toString() ??
          loginData['council_id']?.toString() ??
          '';
      councilName = loginData['councilName']?.toString() ??
          loginData['council_name']?.toString() ??
          '';
      councilCode = loginData['councilCode']?.toString() ??
          loginData['council_code']?.toString() ??
          '';
    }

    String department = '';
    if (loginData['department'] != null && loginData['department'] is Map) {
      final departmentMap = loginData['department'] as Map;
      department = jsonEncode(departmentMap);
    } else {
      department = loginData['department']?.toString() ?? '';
    }

    String portfolio = '';
    if (loginData['portfolio'] != null) {
      portfolio = loginData['portfolio'] is Map
          ? jsonEncode(loginData['portfolio'])
          : loginData['portfolio'].toString();
    }

    final userData = {
      'email': email,
      'token': token,
      'full_name': fullName,
      'role': role,
      'council_id': councilId,
      'council_name': councilName,
      'council_code': councilCode,
      'department': department,
      'portfolio': portfolio,
      'raw_json': jsonEncode(loginData),
      'last_refresh': now,
      'created_at': now,
    };

    await db.delete(tableUsers);
    await db.insert(tableUsers, userData);

    debugPrint('DB: User session saved for $email');
    debugPrint('DB: Council name saved as: "$councilName"');
    debugPrint('DB: Council code saved as: "$councilCode"');
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final db = await database;
      final results = await db.query(tableUsers, limit: 1);
      if (results.isEmpty) return null;
      return results.first;
    } catch (e) {
      debugPrint('DB: Error getting user: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    final user = await getUser();
    return user?['token']?.toString();
  }

  Future<void> updateLastRefresh() async {
    final db = await database;
    await db.update(
      tableUsers,
      {'last_refresh': DateTime.now().millisecondsSinceEpoch},
    );
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete(tableUsers);
    debugPrint('DB: User session cleared');
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null && (user['token']?.toString().isNotEmpty ?? false);
  }

  // ============================================================
  // ASSIGNMENTS CACHE METHODS
  // ============================================================

  Future<void> saveAssignments(List<Map<String, dynamic>> assignments) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final batch = db.batch();
    batch.delete(tableAssignments);

    for (final assignment in assignments) {
      batch.insert(
        tableAssignments,
        {
          'id': assignment['id']?.toString() ?? '',
          'business_id': assignment['businessId']?.toString() ?? '',
          'business_name': assignment['businessName']?.toString() ?? '',
          'category_name': assignment['categoryName']?.toString() ?? '',
          'council_id': assignment['councilId']?.toString() ?? '',
          'council_name': assignment['councilName']?.toString() ?? '',
          'created_at': assignment['createdAt']?.toString(),
          'expiry_date': assignment['expiryDate']?.toString(),
          'final_approved_fee': assignment['finalApprovedFee'] != null
              ? double.tryParse(
              assignment['finalApprovedFee'].toString())
              : null,
          'issued_date': assignment['issuedDate']?.toString(),
          'owner_name': assignment['ownerName']?.toString() ?? '',
          'owner_type': assignment['ownerType']?.toString() ?? '',
          'reference_number':
          assignment['referenceNumber']?.toString() ?? '',
          'status':
          assignment['status']?.toString() ?? 'PENDING_INSPECTION',
          'submitted_by_name':
          assignment['submittedByName']?.toString() ?? '',
          'submitted_by_user_id':
          assignment['submittedByUserId']?.toString() ?? '',
          'type': assignment['type']?.toString() ?? 'NEW',
          'license_type_id': assignment['licenseTypeId']?.toString(),
          'raw_json': jsonEncode(assignment),
          'synced_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint(
        'DB: Saved ${assignments.length} assignments to local cache');
  }

  Future<List<Map<String, dynamic>>> getCachedAssignments() async {
    try {
      final db = await database;
      final results = await db.query(
        tableAssignments,
        orderBy: 'created_at DESC',
      );
      return results.map((row) {
        try {
          final json = jsonDecode(row['raw_json'] as String)
          as Map<String, dynamic>;
          return json;
        } catch (_) {
          return row;
        }
      }).toList();
    } catch (e) {
      debugPrint('DB: Error getting cached assignments: $e');
      return [];
    }
  }

  Future<bool> hasAssignmentCache() async {
    try {
      final db = await database;
      final result = await db.query(tableAssignments, limit: 1);
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CHECKLIST CACHE METHODS
  // ============================================================

  Future<void> saveChecklistCache(
      String licenseTypeId,
      String licenseTypeName,
      Map<String, dynamic> checklistData,
      ) async {
    final db = await database;
    await db.insert(
      tableChecklistCache,
      {
        'license_type_id': licenseTypeId,
        'license_type_name': licenseTypeName,
        'raw_json': jsonEncode(checklistData),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint(
        'DB: Checklist cached for licenseTypeId=$licenseTypeId');
  }

  Future<Map<String, dynamic>?> getCachedChecklist(
      String licenseTypeId) async {
    try {
      final db = await database;
      final results = await db.query(
        tableChecklistCache,
        where: 'license_type_id = ?',
        whereArgs: [licenseTypeId],
        limit: 1,
      );
      if (results.isEmpty) return null;
      final row = results.first;
      return jsonDecode(row['raw_json'] as String)
      as Map<String, dynamic>;
    } catch (e) {
      debugPrint('DB: Error getting cached checklist: $e');
      return null;
    }
  }

  // ============================================================
  // NOTIFICATION METHODS
  // ============================================================

  Future<void> insertNotification(
      Map<String, dynamic> notification) async {
    final db = await database;
    await db.insert(
      tableNotifications,
      notification,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query(
      tableNotifications,
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markNotificationAsRead(String id) async {
    final db = await database;
    await db.update(
      tableNotifications,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final db = await database;
    await db.update(tableNotifications, {'is_read': 1});
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete(
      tableNotifications,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllNotifications() async {
    final db = await database;
    await db.delete(tableNotifications);
  }

  Future<int> getUnreadNotificationCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableNotifications WHERE is_read = 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Count of unread notifications where workflow_stage == 'SUBMIT_INSPECTION'
  Future<int> getPendingInspectionCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableNotifications '
          "WHERE is_read = 0 AND workflow_stage = 'SUBMIT_INSPECTION'",
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // ============================================================
  // PENDING SUBMISSIONS METHODS
  // ============================================================

  Future<int> savePendingSubmission({
    required String applicationId,
    required String businessName,
    required Map<String, dynamic> resultsJson,
  }) async {
    final db = await database;
    final evidenceJson = resultsJson['locationEvidence'] != null
        ? jsonEncode(resultsJson['locationEvidence'])
        : null;

    final id = await db.insert(
      tablePendingSubmissions,
      {
        'application_id': applicationId,
        'business_name': businessName,
        'results_json': jsonEncode(resultsJson),
        'evidence_json': evidenceJson,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
        'status': 'pending',
      },
    );
    debugPrint(
        'DB: Pending submission saved with id=$id for applicationId=$applicationId');
    return id;
  }

  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    try {
      final db = await database;
      return await db.query(
        tablePendingSubmissions,
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
      );
    } catch (e) {
      debugPrint('DB: Error getting pending submissions: $e');
      return [];
    }
  }

  Future<int> getPendingSubmissionsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tablePendingSubmissions WHERE status = ?',
        ['pending'],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markSubmissionSynced(int id) async {
    final db = await database;
    await db.update(
      tablePendingSubmissions,
      {
        'status': 'synced',
        'last_attempt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('DB: Submission id=$id marked as synced');
  }

  Future<void> markSubmissionFailed(int id, String errorMessage) async {
    final db = await database;
    final current = await db.query(
      tablePendingSubmissions,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    final retryCount = current.isEmpty
        ? 0
        : (current.first['retry_count'] as int? ?? 0) + 1;

    await db.update(
      tablePendingSubmissions,
      {
        'status': retryCount >= 5 ? 'failed' : 'pending',
        'retry_count': retryCount,
        'last_attempt': DateTime.now().millisecondsSinceEpoch,
        'error_message': errorMessage,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSyncedSubmissions() async {
    final db = await database;
    await db.delete(
      tablePendingSubmissions,
      where: 'status = ?',
      whereArgs: ['synced'],
    );
  }

  // ============================================================
  // UTILITY
  // ============================================================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(tableUsers);
    await db.delete(tableAssignments);
    await db.delete(tableChecklistCache);
    await db.delete(tablePendingSubmissions);
    await db.delete(tableNotifications);
    debugPrint('DB: All data cleared');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}