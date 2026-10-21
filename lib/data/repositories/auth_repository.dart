import '../datasources/in_memory_database.dart';
import '../models/user.dart';
import 'user_repository.dart';

/// 认证数据仓库：校验账号并把登录态写入 settings 表。
///
/// 演示环境用内存表代替真实后端，账号不存在时自动注册。
class AuthRepository {
  AuthRepository({required UserRepository userRepository, InMemoryDatabase? database})
      : _users = userRepository,
        _db = database ?? InMemoryDatabase.instance;

  /// settings 表中存放当前登录用户主键的键名。
  static const String currentUserKey = 'current_user_id';

  final UserRepository _users;
  final InMemoryDatabase _db;

  /// 读取当前登录用户，未登录时返回 null。
  Future<User?> currentUser() async {
    final id = await _db.readSetting(currentUserKey);
    if (id == null) return null;
    return _users.findById(id);
  }

  /// 登录：校验 credentials 表中的凭证，账号不存在时自动注册。
  ///
  /// 演示账号：`demo` / `123456`。
  Future<User> login({required String account, required String password}) async {
    final normalized = account.trim();
    if (normalized.isEmpty || password.isEmpty) {
      throw Exception('账号或密码不能为空');
    }

    final key = normalized.toLowerCase();
    final credential = await _db.credentials.selectById(key);
    if (credential != null && credential.password != password) {
      throw Exception('密码错误');
    }

    User? user;
    if (credential != null) {
      user = await _users.findById(credential.userId);
    } else {
      user = await _users.findByAccount(normalized) ??
          await _users.create(
            nickname: normalized,
            email: normalized.contains('@') ? normalized : null,
          );
      // 首次登录的账号绑定本次密码，模拟后端写入凭证。
      await _db.credentials.upsert(
        CredentialRow(account: key, password: password, userId: user.id),
      );
    }

    if (user == null) {
      throw Exception('账号数据异常，请重新登录');
    }

    await _db.writeSetting(currentUserKey, user.id);
    return user;
  }

  Future<void> logout() => _db.deleteSetting(currentUserKey);
}
