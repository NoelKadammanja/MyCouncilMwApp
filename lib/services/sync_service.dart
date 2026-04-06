import '../data/local/user_dao.dart';

class SyncService {
  final UserDao userDao;

  SyncService(this.userDao);

  Future<bool> needsRefresh() async {
    final user = await userDao.getUser();
    if (user == null) return true;

    final lastRefresh = user['last_refresh'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 24 hours
    return now - lastRefresh > Duration(hours: 24).inMilliseconds;
  }
}
