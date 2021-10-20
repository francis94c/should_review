import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:should_review/should_review.dart';

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
                height: 10,
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
                      decoration: const InputDecoration(
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
                      initialValue: "2",
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide())),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: _testShouldRateByDaysCriteria,
                child: const Text("Test"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _testShouldRateByDaysCriteria() async {
    if (await ShouldReview.shouldReview(
        minDays: int.parse(_minDaysController.text))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Users has been shown a hypotetical review dialog")));
    }
  }
}
