<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# should_review

This package helps determine if a user should be prompted to rate your app.

The behavior of this package was inspired by the stackoverflow answer at https://stackoverflow.com/a/11284580/2628500 and a couple extra ideas.

You can safely call the determining function `Future<bool> shouldReview()` of this package every time your app launches or at a particular point in your app to determine if you need to prompt for a review.

## Features

* Determine if you need to prompt user for review based on number of days since first app launch, number of times launched.
* Determine the above by a custom criteria. (In Progress)

## Getting started

Add the below to your `pubspec.yaml` file.

```yaml
dependencies:
    should_review: ^0.0.1
```

As this package doesn't actually prompt users for a review, you will need a plugin or a native implementation or other means to do that for you.

A good candidate is the [`in_app_review`](https://pub.dev/packages/in_app_review) plugin.

## Usage

To determine whether to prompt a user for review based on default parameters, do the following.

```dart
import 'package:should_review/should_review.dart';

if (await ShouldReview.shouldReview()) {
    // Prompt user for review.
}
```


## Additional information

For a practical example, see the package example section.

## Contributing

Pull requests are welcome. 

For major changes, please open an issue first to discuss what you would like to change.


## TODO

- [ ] Determine if user should be prompted for a review based on a custom criteria.
- [ ] Get next prompt date.
- [ ] Get number of times launched.
- [ ] Get number of days since first launch.
