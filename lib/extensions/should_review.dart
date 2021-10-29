import 'package:shared_preferences/shared_preferences.dart';
import 'package:should_review/config/pref_keys.dart';
import 'package:should_review/should_review.dart';

extension ShouldReviewExtension on ShouldReview {
  /// Resets all flags in the system's shared preferences.
  /// Basically this is like taking the app in terms of this packag, to the
  /// state it was when the app was first installed and launched.
  static Future<void> reset({customCriteriaKeys = const []}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefTimesLaunched);
    await prefs.remove(prefLastReturnedTrue);
    await prefs.remove(prefShouldReview);
    await prefs.remove(prefFirstLaunchDate);
    await prefs.remove(prefInDaysCoolDownMode);
    await prefs.remove(prefInTimesLaunchedCoolDownMode);

    customCriteriaKeys.forEach((key) async {
      await prefs.remove(prefCustomCriteriaPrefix + key);
      await prefs.remove(prefInCustomCoolDownModePrefix + key);
    });
  }

  /// Resets the flag that indictaes that a true value has been returned by the
  /// `ShouldReview.shouldReview()` method in the last 24 hours (1 Day).
  static Future<void> resetReturnedTrueTodayFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefLastReturnedTrue);
  }
}
