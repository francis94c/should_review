extension DateTimeExtension on DateTime {
  static DateTime? _customTime;

  static DateTime now() {
    return _customTime ?? DateTime.now();
  }

  static set customTime(DateTime? customTime) {
    _customTime = customTime;
  }

  static DateTime? get customTime {
    return _customTime;
  }
}
