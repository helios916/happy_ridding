/// 骑行数据格式化工具。
class FormatUtils {
  FormatUtils._();

  /// 时长 -> HH:MM:SS。
  static String duration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// 米 -> 公里。
  static String distance(double meters, {int fractionDigits = 2}) {
    return (meters / 1000).toStringAsFixed(fractionDigits);
  }

  /// m/s -> km/h。
  static String speed(double metersPerSecond, {int fractionDigits = 1}) {
    return (metersPerSecond * 3.6).toStringAsFixed(fractionDigits);
  }
}
