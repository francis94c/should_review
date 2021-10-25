extension DateTimeExtension on DateTime {
  /// Time to override system time.
  static DateTime? _customTime;

  /// Get current system time according to ShouldReview.
  static DateTime now() {
    return _customTime ?? DateTime.now();
  }

  /// Set a custome time that overrides the ShouldReview system time.
  static set customTime(DateTime? customTime) {
    _customTime = customTime;
  }

  /// Get the custom time that overires the ShouldReview system time.
  static DateTime? get customTime {
    return _customTime;
  }
}
