/// 全局常量与骑行采样参数。
class AppConstants {
  AppConstants._();

  static const String appName = 'Happy Ridding';

  /// 后端服务地址，接入真实接口时修改此处。
  static const String apiBaseUrl = 'https://api.example.com/v1';

  /// 小于该位移的采样点视为抖动，不计入里程（单位：米）。
  static const double minMoveDistanceMeters = 5;

  /// 采样间隔。
  static const Duration trackSampleInterval = Duration(seconds: 2);

  /// 低于该速度视为停止（单位：m/s）。
  static const double autoPauseSpeedMps = 0.5;

  /// 主页路由。
  static const String routeRide = '/ride';
}
