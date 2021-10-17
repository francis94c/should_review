library should_review;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:should_review/config/pref_keys.dart';
import 'package:should_review/extensions/date_time.dart';

/// Should Review Class.
class ShouldReview {
  ShouldReview._();

  /// Determine if you should prompt the user to review your app.
  static Future<bool> shouldReview(
      {Criteria criteria = Criteria.days,
      int minDays = 5,
      int minLaunchTimes = 5,
      coolDownDays = 2,
      int coolDownLaunchTimes = 4}) async {
    // Get SharedPrefernce Instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if we need to go further (has a call to neverReview() been made before)?
    if (!(prefs.getBool(prefShouldReview) ?? true)) {
      return false;
    }

    await _syncFirstLaunchDate(prefs);

    // The goal here is to see all condition we can returen false and do that.
    // If execution get s to the tail of this function then we should probably be returning true.
    if (criteria == Criteria.days) {
      DateTime firstLaunchDate =
          DateTime.parse(prefs.getString(prefFirstLaunchDate)!);
      DateTime now = DateTimeExtension.now();

      // Irregular condition.
      if (firstLaunchDate.isAfter(now)) return false;

      if (prefs.getBool(prefInDaysCoolDownMode) ?? false) {
        firstLaunchDate.add(Duration(days: minDays));
        if (firstLaunchDate.difference(now).inDays % coolDownDays != 0) {
          return false;
        }
      } else {
        if (firstLaunchDate.difference(now).inDays < minDays) {
          return false;
        } else {
          // We are past the min days. Enter cool down mode.
          _enterCoolDownMode(prefs, Criteria.days);
        }
      }
    } else {
      // Launch times criteria
      int timesLaunched = prefs.getInt(prefTimesLaunched) ?? 1;
      if (prefs.getBool(prefInTimesLaunchedCoolDownMode) ?? false) {
        timesLaunched - minLaunchTimes;
        if (timesLaunched <= 0) return false;
        if (timesLaunched % coolDownLaunchTimes != 0) {
          return false;
        }
      } else {
        if (timesLaunched < minLaunchTimes) {
          return false;
        } else {
          // We are past the min launch times. Enter cool down mode.
          _enterCoolDownMode(prefs, Criteria.timesLaunched);
        }
      }
    }

    if (!_hasReturnedTrueToday(prefs)) {
      _recordLastReturnedTrue(prefs);
      return true;
    } else {
      return false;
    }
  }

  /// Increments the number of times the app was launched.
  static Future<void> recordLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(prefTimesLaunched, (prefs.getInt(prefTimesLaunched) ?? 0) + 1);
    _syncFirstLaunchDate(prefs);
  }

  /// Enter cooldown mode.
  /// At this point, minDays or minLaunchTimes do not effectively count, but coolDownInterval values.
  static Future<void> _enterCoolDownMode(
      SharedPreferences prefs, Criteria criteria) async {
    if (criteria == Criteria.days) {
      await prefs.setBool(prefInDaysCoolDownMode, true);
    } else {
      // Times launched criteria.
      await prefs.setBool(prefInTimesLaunchedCoolDownMode, true);
    }
  }

  /// Set shouldReview() to never return true again. this is useful when a user has replied your prompt with 'Never'.
  static Future<void> neverReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(prefShouldReview, false);
    _syncFirstLaunchDate(prefs);
  }

  /// Set first launch date if not set.
  static Future<void> _syncFirstLaunchDate(SharedPreferences prefs) async {
    if (prefs.getString(prefFirstLaunchDate) == null) {
      prefs.setString(prefFirstLaunchDate, DateTimeExtension.now().toString());
    }
  }

  /// Check if we have returned true today.
  static bool _hasReturnedTrueToday(SharedPreferences prefs) {
    DateTime lastReturnedTrue =
        DateTime.parse(prefs.getString(prefLastReturnedTrue)!);
    return lastReturnedTrue.difference(DateTimeExtension.now()).inDays == 0;
  }

  /// Record the last time we returned true.
  static bool _recordLastReturnedTrue(SharedPreferences prefs) {
    prefs.setString(prefLastReturnedTrue, DateTimeExtension.now().toString());
    return true;
  }
}

enum Criteria { timesLaunched, days }
