import '../datasources/in_memory_database.dart';
import '../models/user.dart';

/// 用户数据仓库：对应 users 表。
class UserRepository {
  UserRepository({InMemoryDatabase? database})
      : _db = database ?? InMemoryDatabase.instance;

  final InMemoryDatabase _db;

  Future<User?> findById(String id) => _db.users.selectById(id);

  /// 按邮箱或昵称查找用户。
  Future<User?> findByAccount(String account) async {
    final rows = await _db.users.selectWhere(
      (user) => user.email == account || user.nickname == account,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// 排行榜：按累计里程倒序。
  Future<List<User>> leaderboard({int limit = 20}) async {
    final rows = await _db.users.selectAll();
    rows.sort((a, b) => b.totalDistance.compareTo(a.totalDistance));
    return rows.take(limit).toList();
  }

  /// 新增用户。
  Future<User> create({required String nickname, String? email}) {
    final user = User(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      nickname: nickname,
      email: email,
    );
    return _db.users.upsert(user);
  }

  /// 更新用户资料（昵称、累计成绩等）。
  Future<User> update(User user) => _db.users.upsert(user);
}
