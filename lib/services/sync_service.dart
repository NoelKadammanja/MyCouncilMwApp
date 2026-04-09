import 'package:local_govt_mw/data/local/database_helper.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';

/// Legacy-compatible SyncService.
/// Now delegates to [DatabaseHelper] and [UserDao] which both use SQLite.
class SyncService {
  final UserDao userDao;

  SyncService(this.userDao);

  /// Returns true if the cached user data is older than 24 hours.
  Future<bool> needsRefresh() async {
    final user = await userDao.getUser();
    if (user == null) return true;

    final lastRefresh = user['last_refresh'] as int? ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Refresh if data is older than 24 hours
    return now - lastRefresh > const Duration(hours: 24).inMilliseconds;
  }

  /// Returns true if assignments cache is empty.
  Future<bool> needsAssignmentRefresh() async {
    final db = DatabaseHelper();
    return !(await db.hasAssignmentCache());
  }
}