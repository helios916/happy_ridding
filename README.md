# happy_ridding

骑行记录 App：记录轨迹、时长与配速，帮助你坚持锻炼。

## 技术栈

- Flutter + Material 3
- 状态管理：provider（ChangeNotifier）
- 路由：go_router
- 定位/地图：geolocator + flutter_map（OpenStreetMap 瓦片）
- 数据层：内存数据库（`InMemoryDatabase`）模拟真实 DB 的建表 / CRUD / 种子数据
- 网络：http
- 图表：fl_chart

## 目录结构

```
lib/
├── main.dart                    # 入口：依赖注入 + 启动
├── app.dart                     # MaterialApp 配置
├── core/                        # 基础设施
│   ├── constants/               # 全局常量
│   ├── theme/                   # 主题
│   ├── router/                  # 路由表
│   ├── network/                 # HTTP 客户端封装
│   └── utils/                   # 格式化工具
├── data/
│   ├── datasources/             # 内存数据库：模拟 users / rides / settings 表
│   ├── models/                  # 数据模型：Ride / TrackPoint / User
│   ├── services/                # 定位等平台服务
│   └── repositories/            # 数据仓库：认证 / 骑行记录 / 用户
├── state/                       # 全局状态：骑行/登录/统计
├── features/                    # 按业务功能分层
│   ├── ride/                    # 骑行记录（地图、指标、控制栏）
│   ├── history/                 # 历史记录与统计
│   ├── auth/                    # 登录与个人中心
│   └── social/                  # 排行榜
└── widgets/                     # 跨功能公共组件
```

## 功能模块

| 模块 | 说明 | 主要文件 |
| --- | --- | --- |
| 骑行记录 | GPS 轨迹、距离/时长/配速、暂停与结束 | `features/ride/`、`state/ride_provider.dart` |
| 历史与统计 | 骑行列表、累计里程、近 7 天柱状图 | `features/history/`、`state/stats_provider.dart` |
| 用户与登录 | 登录、用户信息、退出 | `features/auth/`、`state/auth_provider.dart` |
| 社交/排行榜 | 骑行排行榜 | `features/social/` |

## 运行

```bash
flutter pub get
flutter run
```

## 数据层说明

演示版没有真实数据库，所有模块统一通过内存数据库读写：

- `data/datasources/in_memory_database.dart`：`InMemoryTable<T>` 提供 `selectAll / selectById / selectWhere / upsert / deleteById / truncate`，并带 60ms 延迟模拟 I/O；`InMemoryDatabase` 单例维护 `users`、`rides`、`settings`、`credentials` 四张表，启动时写入演示种子数据。
- `data/repositories/`：Repository 封装表访问，`AuthRepository` / `RideRepository` / `UserRepository` 的登录态、骑行记录、排行榜数据全部落到内存表。
- 状态层只依赖 Repository，替换为 sqflite / Drift / 后端 API 时保持方法签名不变即可。

## 登录态鉴权

- 路由守卫在 `core/router/app_router.dart`：未登录只放行 `/login`，其余页面一律重定向到登录页；登录态变化通过 `AuthProvider` 作为 `refreshListenable` 触发重新鉴权。
- 登录凭证存在 `credentials` 表，演示账号 `demo / 123456`；未知账号首次登录会自动注册并绑定该密码，登录态（当前用户 id）写入 `settings` 表，重启后自动恢复。

## 后续接入点

- 后端接口：将 `data/repositories/` 的实现替换为真实 API，配置 `AppConstants.apiBaseUrl`
- 本地持久化：把 `InMemoryDatabase` 换成 sqflite / Drift，Repository 无需改动
- 地图：`flutter_map` 默认使用 OSM 公共瓦片，正式发布请替换为自有/商用瓦片服务
- 认证：接入真实登录后，将 token 写入 `ApiClient.setToken()`
