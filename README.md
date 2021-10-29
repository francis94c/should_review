# should_review

[![Build](https://github.com/francis94c/should_review/actions/workflows/main.yml/badge.svg)](https://github.com/francis94c/should_review/actions/workflows/main.yml) [![codecov](https://codecov.io/gh/francis94c/should_review/branch/master/graph/badge.svg?token=KCPSZJHEO9)](https://codecov.io/gh/francis94c/should_review) [![pub package](https://img.shields.io/pub/v/should_review.svg)](https://pub.dev/packages/should_review) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This package helps determine if a user should be prompted to rate your app.

The behavior of this package was inspired by the stackoverflow answer at https://stackoverflow.com/a/11284580/2628500 and a couple extra ideas.

You can safely call the determining function `Future<bool> shouldReview()` of this package every time your app launches or at a particular point in your app to determine if you need to prompt for a review.

## Features

- Determine if you need to prompt user for review based on number of days since first app launch, number of times launched.
- Determine the above by a custom criteria. (In Progress)

## Getting started

Add the below to your `pubspec.yaml` file.

```yaml
dependencies:
  should_review: ^0.0.1
```

As this package doesn't actually prompt users for a review, you will need a plugin or a native implementation or other means to do that for you.

A good candidate is the [`in_app_review`](https://pub.dev/packages/in_app_review) plugin.

## Usage

There are currently two ways or criteria with which you can use this package.

1. Using Days (`Criteria.days`) criteria (Using number of days since first app launch and subsequent set days interval after that has elapsed).
2. Using Times Launched (`Criteria.timesLaunched`) criteria (Using number of times app has been launched).

### Using Days Criteria

To determine whether to prompt a user for review based on days criteria which is actually the default criteria do the following.

```dart
import 'package:should_review/should_review.dart';

if (await ShouldReview.shouldReview()) {
    // Prompt user for review.
    ShouldReview.neverReview(); // This ensures the shouldReview function never returns true again.
}
```

or outright provide arguments while calling the function as below.

```dart
import 'package:should_review/should_review.dart';

if (await ShouldReview.shouldReview(
    criteria: Criteria.days,
    minDays: 5,
    coolDownDays: 2,
    )) {
    // Prompt user for review.
    ShouldReview.neverReview(); // This ensures the shouldReview function never returns true again.
}
```
__NB:__ For the above to work as expected, there is one thing you have to put in place, which is the `recordLaunch` function.

The `recordLaunch` function must be called somewhere in your app that runs once the app is launched. Suitably in your `lib\main.dart` file or in the `initState` of your Dashboard widget for instance.

This enables the package record how many times the app was launched and use it while determining review possibility with the times launched criteria.

### Using Launch Times Criteria

To determine whether to prompt a user for review based on launch times criteria do the following.

```dart
import 'package:should_review/should_review.dart';

if (await ShouldReview.shouldReview(
    criteria: Criteria.launchTimes,
    minLaunchTimes: 8,
    coolDownLaunchTimes: 4,
    )) {
    // Prompt user for review.
    ShouldReview.neverReview(); // This ensures the shouldReview function never returns true again.
}
```

__NB:__ The `shouldReview` function can only return `true` __once__ a day.

### Parameters

| Parameter             | Description                                                                                                                                                                                                                                                 | Example                                   |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `criteria`            | The criteria to use for determining if you should prompt a user for review.                                                                                                                                                                                 | `Criteria.days`, `Criteria.timesLaunched` |
| `minDays`             | The minimum number of days since first app launch to prompt a user for review.                                                                                                                                                                              | `5`, `8`, `2`                             |
| `coolDownDays`        | The number of days after the minimum days has elapsed to prompt a user for review. In other words, if you provided `2` to this parameter, it means that every `2` days, the `shouldReview` function will return true if `neverReview` has not been called. | `2`, `3`, `1`                             |
| `minLaunchTimes`      | The number of times the app has to be launched before the `shouldReview` function can return true.                                                                                                                                                          | `8`, `5`                                  |
| `coolDownLaunchTimes` | same as `coolDownDays` but for the launch times criteria.                                                                                                                                                                                                   | `3`, `5`                                  |

## Additional information

For a practical example, see the package example section.

## Contributing

Pull requests are welcome.

Send pull requests to the `develop` branch.

For major changes, please open an issue first to discuss what you would like to change.

## TODO

- [x] Determine if user should be prompted for a review based on a custom criteria.
- [ ] Determine if user should be prompted for a review based on aggregated custom criteria.
- [ ] Get next prompt date.
- [x] Get number of times app launched.
- [ ] Get number of days since first launch.
