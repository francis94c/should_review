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

* Determine if you need to prompt user for review based on number of days since first app launch, number of times launched, or a custom criteria.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
