import 'package:flutter/material.dart';
import 'package:minesweeper/screens/main_view.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "MineSweeper",
      home: MainView(),
    );
  }
}
