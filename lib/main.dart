import 'package:flutter/material.dart';
import 'package:minesweeper/screens/game_view.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: GameView(
        sizeX: 8,
        sizeY: 16,
        mineCount: 10,
      ),
    );
  }
}
