import 'package:shared_preferences/shared_preferences.dart';
import 'package:should_review/config/pref_keys.dart';
import 'package:should_review/should_review.dart';

extension ShouldReviewExtension on ShouldReview {
  static Future<void> reset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefTimesLaunched);
    await prefs.remove(prefLastReturnedTrue);
    await prefs.remove(prefShouldReview);
    await prefs.remove(prefFirstLaunchDate);
    await prefs.remove(prefInDaysCoolDownMode);
    await prefs.remove(prefInTimesLaunchedCoolDownMode);
  }
}
