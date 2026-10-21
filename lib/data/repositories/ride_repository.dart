import '../datasources/in_memory_database.dart';
import '../models/ride.dart';

/// 骑行记录数据仓库：对应 rides 表。
class RideRepository {
  RideRepository({InMemoryDatabase? database})
      : _db = database ?? InMemoryDatabase.instance;

  final InMemoryDatabase _db;

  /// 全部记录，按开始时间倒序。
  Future<List<Ride>> findAll() async {
    final rows = await _db.rides.selectAll();
    rows.sort((a, b) => b.startTime.compareTo(a.startTime));
    return rows;
  }

  Future<Ride?> findById(String id) => _db.rides.selectById(id);

  /// 新增或覆盖同 id 的记录。
  Future<Ride> save(Ride ride) => _db.rides.upsert(ride);

  Future<bool> delete(String id) => _db.rides.deleteById(id);
}
