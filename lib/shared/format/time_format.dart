/// 操作日志统一的时间戳格式：`2026-10-08 21:34`。
///
/// 历史记录会把该字符串原样存进本地文件并在界面上展示，因此必须带上日期，
/// 只写时间点会让用户无法判断某条记录是哪天产生的。
String formatHistoryTimestamp([DateTime? value]) {
  final time = value ?? DateTime.now();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)}';
}
