library should_review;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:should_review/config/pref_keys.dart';
import 'package:should_review/extensions/date_time.dart';

/// Should Review Class.
class ShouldReview {
  ShouldReview._();

  /// Determine if you should prompt the user to review your app.
  /// [criteria] - Criteria by which to check shouldReview.
  static Future<bool> shouldReview(
      {Criteria criteria = Criteria.days,
      int minDays = 5,
      int? coolDownDays = 2,
      int minLaunchTimes = 5,
      int? coolDownLaunchTimes = 4,
      String? customCriteriaKey,
      int? minCustomCriteriaValue,
      int? coolDownCustomCriteriaInterval}) async {
    // Get SharedPrefernce Instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if we need to go further (has a call to neverReview() been made before)?
    if (!(prefs.getBool(prefShouldReview) ?? true)) {
      return false;
    }

    await _syncFirstLaunchDate(prefs);
    // The goal here is to see all conditions we can return false and do that.
    // If execution get s to the tail of this function then we should probably be returning true.
    switch (criteria) {
      case Criteria.days:
        // Days Criteria.
        DateTime firstLaunchDate =
            DateTime.parse(prefs.getString(prefFirstLaunchDate)!);
        DateTime now = DateTimeExtension.now();

        // Irregular condition.
        if (firstLaunchDate.isAfter(now)) {
          return false;
        }

        if (prefs.getBool(prefInDaysCoolDownMode) ?? false) {
          if (coolDownDays == null) return false;
          firstLaunchDate = firstLaunchDate.add(Duration(days: minDays));
          if (now.difference(firstLaunchDate).inDays % coolDownDays != 0) {
            return false;
          }
        } else {
          if (now.difference(firstLaunchDate).inDays < minDays) {
            return false;
          } else {
            // We are past the min days. Enter cool down mode.
            _enterCoolDownMode(prefs, Criteria.days);
          }
        }
        break;
      case Criteria.timesLaunched:
        // Times Launched Criteria.
        int timesLaunched = prefs.getInt(prefTimesLaunched) ?? 1;
        if (prefs.getBool(prefInTimesLaunchedCoolDownMode) ?? false) {
          if (coolDownLaunchTimes == null) return false;
          timesLaunched -= minLaunchTimes;
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
        break;
      case Criteria.custom:
        // Custom criteria.
        if (customCriteriaKey == null || minCustomCriteriaValue == null) {
          throw ArgumentError(
              'Custom Criteria requires customCriteriaKey, minCustomCriteriaValue and coolDownCustomCriteriaInterval to be set.');
        }

        int customCriteriaValue =
            prefs.getInt(prefCustomCriteriaPrefix + customCriteriaKey) ?? 0;
        if (prefs.getBool(prefInCustomCoolDownModePrefix + customCriteriaKey) ??
            false) {
          if (coolDownCustomCriteriaInterval == null) return false;
          customCriteriaValue -= minCustomCriteriaValue;
          if (customCriteriaValue <= 0) return false;
          if (customCriteriaValue % coolDownCustomCriteriaInterval != 0) {
            return false;
          }
        } else {
          if (customCriteriaValue < minCustomCriteriaValue) {
            return false;
          } else {
            // We are past the min launch times. Enter cool down mode.
            _enterCoolDownMode(prefs, Criteria.custom, key: customCriteriaKey);
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
    await prefs.setInt(
        prefTimesLaunched, (prefs.getInt(prefTimesLaunched) ?? 0) + 1);
    _syncFirstLaunchDate(prefs);
  }

  /// Increments the number of times a custom criteria was met.
  static Future<void> recordCustomCriteriaMet(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefCustomCriteriaPrefix + key,
        (prefs.getInt(prefCustomCriteriaPrefix + key) ?? 0) + 1);
    _syncFirstLaunchDate(prefs);
  }

  /// Get number of times app was launched i.e recordLaunch() was called.
  static Future<int> getTimesAppLaunched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prefTimesLaunched) ?? 0;
  }

  /// Get number of times custom criteria was met i.e .how manu times
  /// recordCustomCriteriaMet() was called for a custom criteria.
  static Future<int> getTimesCustomCriteriaWasMet(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prefCustomCriteriaPrefix + key) ?? 0;
  }

  /// Enter cooldown mode.
  /// At this point, minDays or minLaunchTimes do not effectively count, but
  /// coolDownInterval values.
  static Future<void> _enterCoolDownMode(
      SharedPreferences prefs, Criteria criteria,
      {String? key}) async {
    switch (criteria) {
      case Criteria.days:
        // Days criteria.
        await prefs.setBool(prefInDaysCoolDownMode, true);
        break;
      case Criteria.timesLaunched:
        // Times launched criteria.
        await prefs.setBool(prefInTimesLaunchedCoolDownMode, true);
        break;
      case Criteria.custom:
        // Custom criteria.
        await prefs.setBool(prefInCustomCoolDownModePrefix + key!, true);
        break;
    }
  }

  /// Set shouldReview() to never return true again. this is useful when a user has replied your prompt with 'Never'.
  static Future<void> neverReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(prefShouldReview, false);
    _syncFirstLaunchDate(prefs);
  }

  static Future<void> incrementCustomCriteria(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefCustomCriteriaPrefix + key,
        (prefs.getInt(prefCustomCriteriaPrefix + key) ?? 0) + 1);
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
    if (prefs.getString(prefLastReturnedTrue) == null) {
      return false;
    }
    DateTime lastReturnedTrue =
        DateTime.parse(prefs.getString(prefLastReturnedTrue)!);
    return DateTimeExtension.now().difference(lastReturnedTrue).inDays == 0;
  }

  /// Record the last time we returned true.
  static bool _recordLastReturnedTrue(SharedPreferences prefs) {
    prefs.setString(prefLastReturnedTrue, DateTimeExtension.now().toString());
    return true;
  }
}

/// Should Review calculation criteria
/// [timesLaunched] - Check shouldReview based on how many times app launch was
/// recorded.
/// [days] - Check shouldReview based on how many days have passed since first
/// launch.
/// [custom] - Check shouldReview based on a custom criteria.
enum Criteria { timesLaunched, days, custom }
