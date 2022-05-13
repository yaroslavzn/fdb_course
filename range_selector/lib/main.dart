import 'package:flutter/material.dart';
import 'package:range_selector/range_selector_page.dart';

void main(List<String> args) {
  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RangeSelectorPage(),
      title: 'Range Selector',
      debugShowCheckedModeBanner: true,
    );
  }
}
