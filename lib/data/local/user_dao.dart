import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/data/local/database_helper.dart';

/// Data-access object for the logged-in user.
/// Uses SQLite via [DatabaseHelper] so the session survives app restarts
/// and is queryable by other DAOs without SharedPreferences.
class UserDao {
  final DatabaseHelper _db = DatabaseHelper();

  // ------------------------------------------------------------------
  // WRITE
  // ------------------------------------------------------------------

  /// Persist the full login payload returned by the API.
  Future<void> saveUser(Map<String, dynamic> data) async {
    await _db.saveUser(data);
  }

  /// Update the last_refresh timestamp (called after a successful token
  /// refresh or after assignments are re-fetched from the server).
  Future<void> updateLastRefresh() async {
    await _db.updateLastRefresh();
  }

  // ------------------------------------------------------------------
  // READ
  // ------------------------------------------------------------------

  /// Returns the stored user row as a flat map, or null if not logged in.
  /// Keys returned: token, email, full_name (as "name" + "fullName"),
  /// role, council_id, council_name, department, portfolio, last_refresh.
  Future<Map<String, dynamic>?> getUser() async {
    final row = await _db.getUser();
    if (row == null) return null;

    // Merge raw_json fields so callers that rely on camelCase keys still work
    Map<String, dynamic> merged = {};
    try {
      final raw = jsonDecode(row['raw_json'] as String? ?? '{}') as Map<String, dynamic>;
      merged = Map<String, dynamic>.from(raw);
    } catch (_) {}

    // Always overlay the DB columns (snake_case) and add convenience aliases
    merged['token'] = row['token'];
    merged['email'] = row['email'];
    merged['role'] = row['role'];
    merged['council_id'] = row['council_id'];
    merged['council_name'] = row['council_name'];
    merged['department'] = row['department'];
    merged['portfolio'] = row['portfolio'];
    merged['last_refresh'] = row['last_refresh'];

    // Convenience aliases used in various screens
    merged['name'] = row['full_name'];
    merged['fullName'] = row['full_name'];

    return merged;
  }

  /// Returns only the auth token, or null if not logged in.
  Future<String?> getToken() async => _db.getToken();

  /// Returns true when a valid session exists.
  Future<bool> isLoggedIn() async => _db.isLoggedIn();

  // ------------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------------

  /// Wipe the user session (called on logout).
  Future<void> clearUser() async {
    await _db.clearUser();
    debugPrint('UserDao: session cleared');
  }

  /// Backward compatibility method for code that calls clear()
  Future<void> clear() async {
    await clearUser();
  }
}