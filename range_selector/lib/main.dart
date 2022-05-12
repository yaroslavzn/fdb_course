import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Range Selector',
          ),
        ),
        body: const RangeSelectorPage(),
        floatingActionButton: const FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: null,
        ),
      ),
    );
  }
}

class RangeSelectorPage extends StatefulWidget {
  const RangeSelectorPage({Key? key}) : super(key: key);

  @override
  State<RangeSelectorPage> createState() => _RangeSelectorPageState();
}

class _RangeSelectorPageState extends State<RangeSelectorPage> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Minimum',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: true,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Maximum',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
