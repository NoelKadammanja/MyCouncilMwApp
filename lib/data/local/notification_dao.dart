import 'package:flutter/material.dart';
import 'package:local_govt_mw/data/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDao {
  final DatabaseHelper _db = DatabaseHelper();

  /// Get all notifications ordered by creation time (newest first)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await _db.database;
    return await db.query(
      'notifications',
      orderBy: 'created_at DESC',
    );
  }

  /// Insert a new notification
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    try {
      final db = await _db.database;
      await db.insert(
        'notifications',
        notification,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Notification inserted: ${notification['id']}');
    } catch (e) {
      debugPrint('Error inserting notification: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final db = await _db.database;
      await db.update(
        'notifications',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      debugPrint('Notification marked as read: $notificationId');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final db = await _db.database;
      await db.update(
        'notifications',
        {'is_read': 1},
      );
      debugPrint('All notifications marked as read');
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete a specific notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'notifications',
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      debugPrint('Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Delete notifications by assignment ID
  Future<void> deleteNotificationsByAssignment(String assignmentId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'notifications',
        where: 'assignment_id = ?',
        whereArgs: [assignmentId],
      );
      debugPrint('Notifications deleted for assignment: $assignmentId');
    } catch (e) {
      debugPrint('Error deleting notifications by assignment: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      final db = await _db.database;
      await db.delete('notifications');
      debugPrint('All notifications cleared');
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Get notifications for a specific assignment
  Future<List<Map<String, dynamic>>> getNotificationsByAssignment(
      String assignmentId) async {
    try {
      final db = await _db.database;
      return await db.query(
        'notifications',
        where: 'assignment_id = ?',
        whereArgs: [assignmentId],
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      debugPrint('Error getting notifications by assignment: $e');
      return [];
    }
  }
}