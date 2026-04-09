import 'package:sqflite/sqflite.dart';
import 'package:local_govt_mw/data/local/database_helper.dart';

class NotificationDao {
  final DatabaseHelper _db = DatabaseHelper();
  static const String tableName = 'notifications';

  // Create table if not exists (called from DatabaseHelper during migration)
  Future<void> createTable() async {
    final db = await _db.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
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
  }

  // Insert a new notification
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    final db = await _db.database;
    await db.insert(
      tableName,
      notification,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all notifications (most recent first)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await _db.database;
    return await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );
  }

  // Mark a single notification as read
  Future<void> markAsRead(String id) async {
    final db = await _db.database;
    await db.update(
      tableName,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final db = await _db.database;
    await db.update(
      tableName,
      {'is_read': 1},
    );
  }

  // Delete a single notification
  Future<void> deleteNotification(String id) async {
    final db = await _db.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all notifications
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete(tableName);
  }

  // Get count of unread notifications
  Future<int> getUnreadCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE is_read = 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}