import 'package:flutter_test/flutter_test.dart';
import 'package:should_review/extensions/date_time.dart';
import 'package:should_review/extensions/should_review.dart';

import 'package:should_review/should_review.dart';

void main() {
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
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 6 Days in Future.
    expect(await ShouldReview.shouldReview(), false);
    DateTimeExtension.customTime = DateTimeExtension.customTime!
        .add(const Duration(days: 1)); // 7 Days in Future.
    expect(await ShouldReview.shouldReview(), true);
  });

  test('Cannot return true multiple times the same day', () async {
    expect(await ShouldReview.shouldReview(), false);
    expect(await ShouldReview.shouldReview(), false);
  });
}
