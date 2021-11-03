import 'package:flutter_test/flutter_test.dart';
import 'package:should_review/extensions/date_time.dart';
import 'package:should_review/extensions/should_review.dart';

import 'package:should_review/should_review.dart';

void main() async {
  // Days Criteria Test (Default)
  test('Return false on default parameters and first try', () async {
    await ShouldReviewExtension.reset();
    expect(await ShouldReview.shouldReview(), false);
  });

  test('Return true on default parameters after 5 days', () async {
    await ShouldReviewExtension.reset();
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTime.now();
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 1 Day in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 2 Days in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 3 Days in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 4 Days in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 5 Days in Future.
    expect(await ShouldReview.shouldReview(), true);
  });

  test('Verify behaviour in cool down mode', () async {
    await ShouldReviewExtension.reset();
    DateTimeExtension.customTime = null;
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime =
        DateTime.now().add(const Duration(days: 5)); // 5 Days in Future
    expect(await ShouldReview.shouldReview(), true);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 6 Days in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 7 Days in Future.
    expect(await ShouldReview.shouldReview(), true);
  });

  test('Verify behaviour in cool down mode for null days interval', () async {
    await ShouldReviewExtension.reset();
    DateTimeExtension.customTime = null;
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime =
        DateTime.now().add(const Duration(days: 5)); // 5 Days in Future
    expect(await ShouldReview.shouldReview(), true);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 6 Days in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 7 Days in Future.
    expect(await ShouldReview.shouldReview(coolDownDays: null), false);
  });

  test("Cannot return 'true' multiple times the same day", () async {
    await ShouldReviewExtension.reset();
    DateTimeExtension.customTime = null;
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime =
        DateTime.now().add(const Duration(days: 5)); // 5 Days in Future
    expect(await ShouldReview.shouldReview(), true);
    expect(await ShouldReview.shouldReview(), false);
    expect(await ShouldReview.shouldReview(), false);
    expect(await ShouldReview.shouldReview(), false);
  });

  // Times Launched Criteria
  test("Return 'false' on first try (launch)", () async {
    await ShouldReviewExtension.reset();
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
  });

  test('Return true after 4 launches', () async {
    await ShouldReviewExtension.reset();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 1);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 2);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 3);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 4);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 5);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        true);
  });

  test('Verify cooldown behaviour with times launched criteria', () async {
    await ShouldReviewExtension.reset();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 1);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 2);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 3);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 4);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 5);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        true);
    // Cool Down Mode.
    // Coool down launch times = 4
    ShouldReviewExtension.resetReturnedTrueTodayFlag();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 6);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 7);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 8);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 9);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        true);
  });

  test(
      "Cannot return 'true' multiple times the same day (Times launched criteria)",
      () async {
    await ShouldReviewExtension.reset();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 1);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 2);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 3);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 4);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 5);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        true);
    expect(await ShouldReview.shouldReview(), false);
    expect(await ShouldReview.shouldReview(), false);
    expect(await ShouldReview.shouldReview(), false);
  });

  test('Verify behaviour in cool down mode for null times launched interval',
      () async {
    await ShouldReviewExtension.reset();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 1);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 2);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 3);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 4);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 5);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        true);
    // Cool Down Mode.
    // Coool down launch times = 4
    ShouldReviewExtension.resetReturnedTrueTodayFlag();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 6);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 7);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 8);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 9);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.timesLaunched, coolDownLaunchTimes: null),
        false);
  });

  // Custom Criteria
  test("Return 'false' on first try (custom:test)", () async {
    await ShouldReviewExtension.reset(customCriteriaKeys: ["test"]);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            customCriteriaKey: "test",
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2),
        false);
  });

  test("Test Custom Criteria", () async {
    await ShouldReviewExtension.reset(customCriteriaKeys: ["test"]);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 1);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 2);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 3);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 4);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 5);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        true);
  });

  test('Verify cooldown behaviour with custom criteria', () async {
    await ShouldReviewExtension.reset(customCriteriaKeys: ["test"]);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 1);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 2);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 3);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 4);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 5);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        true);
    // Cool Down Mode.
    // Coool down launch times = 4

    // So we can still return true for testing purposes.
    ShouldReviewExtension.resetReturnedTrueTodayFlag();

    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 6);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 7);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        true);

    // So we can still return true for testing purposes.
    await ShouldReviewExtension.resetReturnedTrueTodayFlag();

    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 8);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 9);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        true);
  });

  test('Verify cooldown behaviour with custom criteria for null interval value',
      () async {
    await ShouldReviewExtension.reset(customCriteriaKeys: ["test"]);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 1);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 2);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 3);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 4);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 5);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        true);
    // Cool Down Mode.
    // Coool down launch times = 4

    // So we can still return true for testing purposes.
    ShouldReviewExtension.resetReturnedTrueTodayFlag();

    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 6);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: null,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 7);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: null,
            customCriteriaKey: "test"),
        false); // Normally should return true.

    // So we can still return true for testing purposes.
    await ShouldReviewExtension.resetReturnedTrueTodayFlag();

    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 8);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: null,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 9);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: null,
            customCriteriaKey: "test"),
        false); // Normally should return true
  });

  test("Cannot return 'true' multiple times the same day (Custom criteria)",
      () async {
    await ShouldReviewExtension.reset(customCriteriaKeys: ["test"]);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 1);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 2);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 3);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 4);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 5);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        true);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
  });

  // Never Rate Region
  test("Always return false no matter what.", () async {
    // Days Criteria.
    await ShouldReviewExtension.reset();
    await ShouldReview.neverReview();
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTime.now();
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 5)); // 5 Days in Future.
    expect(await ShouldReview.shouldReview(), false);

    // Times Launched Criteria.
    // Default Min Launch Times is 5.
    await ShouldReviewExtension.reset();
    await ShouldReview.neverReview();
    await ShouldReview.recordLaunch();
    await ShouldReview.recordLaunch();
    await ShouldReview.recordLaunch();
    await ShouldReview.recordLaunch();
    await ShouldReview.recordLaunch();
    expect(await ShouldReview.getTimesAppLaunched(), 5);
    expect(await ShouldReview.shouldReview(criteria: Criteria.timesLaunched),
        false);

    // Custom Criteria.
    // Defaulr Min Launch Times is 5.
    await ShouldReviewExtension.reset(customCriteriaKeys: ["test"]);
    await ShouldReview.neverReview();
    await ShouldReview.recordCustomCriteriaMet("test");
    await ShouldReview.recordCustomCriteriaMet("test");
    await ShouldReview.recordCustomCriteriaMet("test");
    await ShouldReview.recordCustomCriteriaMet("test");
    await ShouldReview.recordCustomCriteriaMet("test");
    expect(await ShouldReview.getTimesCustomCriteriaWasMet("test"), 5);
    expect(
        await ShouldReview.shouldReview(
            criteria: Criteria.custom,
            minCustomCriteriaValue: 5,
            coolDownCustomCriteriaInterval: 2,
            customCriteriaKey: "test"),
        false);
  });
}
