import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:should_review/should_review.dart';

// For Test Purposes.
import 'package:should_review/extensions/date_time.dart';
import 'package:should_review/extensions/should_review.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Should Review Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Should Review Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TextEditing Controllers.
  final TextEditingController _minDaysController = TextEditingController();
  final TextEditingController _coolDownDaysController = TextEditingController();

  // Keys
  final GlobalKey<FormState> _daysCriteriaFormKey = GlobalKey();

  bool _hasPromptedRateApp = false;

  @override
  void initState() {
    super.initState();
    ShouldReviewExtension
        .reset(); // Never call this in real use. This is just for testing.
    _minDaysController.text = '7';
    _coolDownDaysController.text = '2';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Form(
            key: _daysCriteriaFormKey,
            child: Column(
              children: [
                const Text(
                    "Determine if user should rate app by past days after first launch"),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minDaysController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null) {
                            return 'Please enter a number';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            label: Text('Minimum Days before First Prompt'),
                            border:
                                OutlineInputBorder(borderSide: BorderSide())),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _coolDownDaysController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null) {
                            return 'Please enter a number';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            label: Text('Interval Days after First Prompt.'),
                            border:
                                OutlineInputBorder(borderSide: BorderSide())),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  onPressed: _setHypotethicalTodaysDate,
                  color: Colors.blue,
                  child: const Text(
                    "Set Hypotethical Today's Date",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(DateTimeExtension.customTime == null
                    ? "Same as System"
                    : DateTimeExtension.customTime.toString()),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Has Prompted user to Rate App: " +
                      (_hasPromptedRateApp ? "True" : "False"),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  onPressed: _testShouldRateByDaysCriteria,
                  color: Colors.blue,
                  child: const Text(
                    "Test",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  onPressed: _reset,
                  color: Colors.blue,
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  onPressed: _viewLaunchTimesCriteriaExample,
                  color: Colors.blue,
                  child: const Text(
                    "View Launch Times Criteria Example",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  onPressed: _viewCustomCriteriaExample,
                  color: Colors.blue,
                  child: const Text(
                    "Custom Criteria Example",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reset() async {
    await ShouldReviewExtension.reset();
    setState(() {
      _hasPromptedRateApp = false;
      DateTimeExtension.customTime = null;
    });
  }

  void _setHypotethicalTodaysDate() async {
    DateTime? dateTime = await showDatePicker(
      context: context,
      initialDate: DateTimeExtension.customTime == null
          ? DateTime.now()
          : DateTimeExtension.customTime!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (dateTime != null) {
      setState(() => DateTimeExtension.customTime = dateTime);
    }
  }

  void _testShouldRateByDaysCriteria() async {
    // Validate Form Field.
    if (!_daysCriteriaFormKey.currentState!.validate()) {
      return;
    }

    // ignore: avoid_print
    print("Checking Prompt Review Possibility");

    // Should Review.
    if (await ShouldReview.shouldReview(
        criteria: Criteria.days,
        minDays: int.parse(_minDaysController.text),
        coolDownDays: int.parse(_coolDownDaysController.text))) {
      // A good place to use the in_app_review plugin.
      // ignore: avoid_print
      print("Retruned True");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "User has been shown a hypotetical review dialog, this logic will now return true only on the cool down days interval."),
          duration: Duration(seconds: 10),
        ),
      );
      // Call `ShouldReview.neverReview();` to ensure the shouldReview function never returns true again.
      setState(() => _hasPromptedRateApp = true);
    } else {
      // ignore: avoid_print
      print("Returned False");
    }
  }

  void _viewLaunchTimesCriteriaExample() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const LaunchTimesCriteriaExample()));
  }

  void _viewCustomCriteriaExample() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CustomCriteriaExample()));
  }
}

class LaunchTimesCriteriaExample extends StatefulWidget {
  const LaunchTimesCriteriaExample({Key? key}) : super(key: key);

  @override
  _LaunchTimesCriteriaExampleState createState() =>
      _LaunchTimesCriteriaExampleState();
}

class _LaunchTimesCriteriaExampleState
    extends State<LaunchTimesCriteriaExample> {
  // TextEditing Controllers.
  final TextEditingController _minLaunchTimesController =
      TextEditingController();
  final TextEditingController _coolDownLaunchTimesController =
      TextEditingController();

  // Keys
  final GlobalKey<FormState> _launchTimesCriteriaFormKey = GlobalKey();

  bool _hasPromptedRateApp = false;
  int _timesAppLaunched = 0;

  @override
  void initState() {
    super.initState();
    _reset().then((_) => _updateAppLaunchTimesInUI());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Launch Times Criteria Example"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Form(
          key: _launchTimesCriteriaFormKey,
          child: Column(
            children: [
              const Text(
                  "Determine if user should rate app by past days after first launch"),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minLaunchTimesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Please enter a number';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          label: Text('Minimum app launch times'),
                          border: OutlineInputBorder(borderSide: BorderSide())),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _coolDownLaunchTimesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Please enter a number';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          label: Text(
                              'Launch times in interval after minimum app launch times have been met'),
                          border: OutlineInputBorder(borderSide: BorderSide())),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Has Prompted user to Rate App: " +
                    (_hasPromptedRateApp ? "True" : "False"),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "App Launch Times: $_timesAppLaunched",
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: _recordLaunch,
                color: Colors.blue,
                child: const Text(
                  "Record App Launch",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: _testShouldRateByLaunchTimesCriteria,
                color: Colors.blue,
                child: const Text(
                  "Test",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () =>
                    _reset().then((_) => _updateAppLaunchTimesInUI()),
                color: Colors.blue,
                child: const Text(
                  "Reset",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reset() async {
    await ShouldReviewExtension.reset();
    setState(() {
      _hasPromptedRateApp = false;
    });
  }

  /// Record App Launch.
  void _recordLaunch() async {
    await ShouldReview.recordLaunch();
    _updateAppLaunchTimesInUI();
  }

  /// Upate App Launch Times in UI.
  void _updateAppLaunchTimesInUI() {
    ShouldReview.getTimesAppLaunched().then(
        (int launchTimes) => setState(() => _timesAppLaunched = launchTimes));
  }

  void _testShouldRateByLaunchTimesCriteria() async {
    // Validate Form Field.
    if (!_launchTimesCriteriaFormKey.currentState!.validate()) {
      return;
    }

    // ignore: avoid_print
    print("Checking Prompt Review Possibility");

    // Should Review.
    if (await ShouldReview.shouldReview(
        criteria: Criteria.timesLaunched,
        minLaunchTimes: int.parse(_minLaunchTimesController.text),
        coolDownLaunchTimes: int.parse(_coolDownLaunchTimesController.text))) {
      // A good place to use the in_app_review plugin.
      // ignore: avoid_print
      print("Retruned True");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "User has been shown a hypotetical review dialog, this logic will now return true only on the cool down launch times interval."),
          duration: Duration(seconds: 10),
        ),
      );
      // Call `ShouldReview.neverReview();` to ensure the shouldReview function never returns true again.
      setState(() => _hasPromptedRateApp = true);
    } else {
      // ignore: avoid_print
      print("Returned False");
    }
  }
}

class CustomCriteriaExample extends StatefulWidget {
  const CustomCriteriaExample({Key? key}) : super(key: key);

  @override
  _CustomCriteriaExampleState createState() => _CustomCriteriaExampleState();
}

class _CustomCriteriaExampleState extends State<CustomCriteriaExample> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
