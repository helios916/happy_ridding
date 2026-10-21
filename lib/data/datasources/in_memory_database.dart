import '../models/ride.dart';
import '../models/user.dart';

/// 内存表：模拟关系型数据库中的一张表。
///
/// 这里刻意只暴露最小的主键读写能力，接入 sqflite / Drift / 后端 API 时
/// 保持方法签名不变、只替换内部实现即可。
class InMemoryTable<T> {
  InMemoryTable({
    required this.name,
    required String Function(T row) idOf,
    this.latency = Duration.zero,
  }) : _idOf = idOf;

  /// 表名，便于调试输出。
  final String name;

  final String Function(T row) _idOf;

  /// 模拟单次 I/O 耗时，让页面 loading 态在演示时可见。
  final Duration latency;

  final Map<String, T> _rows = <String, T>{};

  /// 当前行数。
  int get rowCount => _rows.length;

  Future<List<T>> selectAll() async {
    await _delay();
    return _rows.values.toList();
  }

  Future<T?> selectById(String id) async {
    await _delay();
    return _rows[id];
  }

  Future<List<T>> selectWhere(bool Function(T row) test) async {
    await _delay();
    return _rows.values.where(test).toList();
  }

  /// 主键已存在则覆盖，否则插入。
  Future<T> upsert(T row) async {
    await _delay();
    _rows[_idOf(row)] = row;
    return row;
  }

  Future<bool> deleteById(String id) async {
    await _delay();
    return _rows.remove(id) != null;
  }

  Future<void> truncate() async {
    await _delay();
    _rows.clear();
  }

  Future<void> _delay() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }
}

/// settings 表的一行。
class SettingRow {
  const SettingRow({required this.key, required this.value});

  final String key;
  final String value;
}

/// credentials 表的一行：登录凭证，主键为小写后的账号。
class CredentialRow {
  const CredentialRow({
    required this.account,
    required this.password,
    required this.userId,
  });

  final String account;
  final String password;
  final String userId;
}

/// 内存数据库：用内存表模拟真实数据库，供演示与本地开发使用。
class InMemoryDatabase {
  InMemoryDatabase._();

  static final InMemoryDatabase instance = InMemoryDatabase._();

  /// 模拟单次查询耗时。
  static const Duration latency = Duration(milliseconds: 60);

  late final InMemoryTable<User> users = InMemoryTable<User>(
    name: 'users',
    idOf: (row) => row.id,
    latency: latency,
  );

  late final InMemoryTable<Ride> rides = InMemoryTable<Ride>(
    name: 'rides',
    idOf: (row) => row.id,
    latency: latency,
  );

  late final InMemoryTable<SettingRow> settings = InMemoryTable<SettingRow>(
    name: 'settings',
    idOf: (row) => row.key,
    latency: latency,
  );

  late final InMemoryTable<CredentialRow> credentials =
      InMemoryTable<CredentialRow>(
    name: 'credentials',
    idOf: (row) => row.account,
    latency: latency,
  );

  bool _seeded = false;

  /// 建表并写入演示数据，重复调用无副作用。
  Future<void> ensureSeeded() async {
    if (_seeded) return;
    _seeded = true;
    for (final user in _seedUsers) {
      await users.upsert(user);
    }
    for (final credential in _seedCredentials) {
      await credentials.upsert(credential);
    }
  }

  /// 清空所有表并重新写入演示数据。
  Future<void> reset() async {
    await users.truncate();
    await rides.truncate();
    await settings.truncate();
    await credentials.truncate();
    _seeded = false;
    await ensureSeeded();
  }

  Future<String?> readSetting(String key) async {
    final row = await settings.selectById(key);
    return row?.value;
  }

  Future<void> writeSetting(String key, String value) async {
    await settings.upsert(SettingRow(key: key, value: value));
  }

  Future<void> deleteSetting(String key) async {
    await settings.deleteById(key);
  }
}

/// 演示用种子数据：模拟其他骑友的累计成绩，用于排行榜。
const List<User> _seedUsers = [
  User(
    id: 'u_1001',
    nickname: '风一样的骑士',
    email: 'feng@example.com',
    totalDistance: 128400,
    totalRides: 36,
  ),
  User(
    id: 'u_1002',
    nickname: '爬坡小王子',
    email: 'climb@example.com',
    totalDistance: 96500,
    totalRides: 28,
  ),
  User(
    id: 'u_1003',
    nickname: '夜骑爱好者',
    email: 'night@example.com',
    totalDistance: 73200,
    totalRides: 41,
  ),
  User(
    id: 'u_1004',
    nickname: '通勤骑士',
    email: 'commute@example.com',
    totalDistance: 41800,
    totalRides: 62,
  ),
  User(
    id: 'u_1005',
    nickname: '湖畔慢骑',
    email: 'lake@example.com',
    totalDistance: 18600,
    totalRides: 12,
  ),
];

/// 演示用登录凭证：账号 `demo` / 密码 `123456` 对应种子用户 u_1001。
const List<CredentialRow> _seedCredentials = [
  CredentialRow(
    account: 'demo',
    password: '123456',
    userId: 'u_1001',
  ),
];
