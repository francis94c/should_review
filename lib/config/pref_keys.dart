/// Share Preferences Keys Prefix.
const String _keyPrefix = "should_review_";

/// Preference key to store number of times app was launched.
const String prefTimesLaunched = "${_keyPrefix}times_launched";

/// Preference key to control if the Should Review logic should run in the first
/// place.
/// If the logic should run, then the shouldReview function will always return
/// false.
const String prefShouldReview = "${_keyPrefix}should_review";

/// Preference key to flag if the logic is in cool down mode for days criteria.
/// Cool down mode means the logic will start considering the minDays &
/// minCooldown days together for days critera.
const String prefInDaysCoolDownMode = "${_keyPrefix}in_days_cool_down_mode";

/// Preference key to flag if the logic is in cool down mode for launch times
/// criteria.
/// Cool down mode means the logic will start considering the  minLaunchTimes &
/// coolDownLaunchTimes  together for launch times criteria.
const String prefInTimesLaunchedCoolDownMode =
    "${_keyPrefix}in_times_launched_cool_down_mode";

/// Preference key to store the first date app was launched.
const String prefFirstLaunchDate = "${_keyPrefix}first_launch_date";

/// Preference key to store the last date true was returned from the
/// shouldReview function.
const String prefLastReturnedTrue = "${_keyPrefix}last_returned_true";
