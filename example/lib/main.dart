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
      body: Container(
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
                          border: OutlineInputBorder(borderSide: BorderSide())),
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
                          border: OutlineInputBorder(borderSide: BorderSide())),
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
              const Divider(),
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
              )
            ],
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
      // ignore: avoid_print
      print("Retruned True");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "User has been shown a hypotetical review dialog, this logic will now return true only on the cool down days interval."),
          duration: Duration(seconds: 10),
        ),
      );
      setState(() => _hasPromptedRateApp = true);
    } else {
      // ignore: avoid_print
      print("Retruned False");
    }
  }
}
