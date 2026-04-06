import 'database_helper.dart';

class NotificationDao {
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await DatabaseHelper.database;
    return await db.query('notifications', orderBy: 'timestamp DESC');
  }

  Future<void> insertNotification(Map<String, dynamic> n) async {
    final db = await DatabaseHelper.database;
    await db.insert('notifications', {
      'title': n['title'] ?? '',
      'body': n['body'] ?? '',
      'timestamp': n['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      'read': n['read'] ?? 0,
      'type': n['type'] ?? '',
    });
  }

  Future<void> markAsRead(int id) async {
    final db = await DatabaseHelper.database;
    await db.update('notifications', {'read': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
