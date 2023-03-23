import 'package:flutter/material.dart';
import 'package:minesweeper/screens/game_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("MineSweeper"),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          var height = constraints.maxHeight;
          var width = constraints.maxWidth;
          // stack UI horizontally
          if (width * 5 > height * 8) {
            return _HorizontalLayout(width: width);
          }
          // stack UI vertically
          else {
            return _VerticalLayout(width: width);
          }
        }),
      ),
    );
  }
}

class _VerticalLayout extends StatelessWidget {
  const _VerticalLayout({
    required this.width,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(color: Colors.blue),
          ),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _NewGameButton(
                  difficulty: "Easy (8 * 16, 10)",
                  sizeX: 8,
                  sizeY: 16,
                  mineCount: 10,
                ),
                _NewGameButton(
                  difficulty: "Medium (10 * 18, 35)",
                  sizeX: 10,
                  sizeY: 18,
                  mineCount: 35,
                ),
                _NewGameButton(
                  difficulty: "Hard (14 * 26, 75)",
                  sizeX: 14,
                  sizeY: 26,
                  mineCount: 75,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _HorizontalLayout extends StatelessWidget {
  const _HorizontalLayout({
    required this.width,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(color: Colors.blue),
          ),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.025,
              // vertical: height * 0.3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _NewGameButton(
                  difficulty: "Easy (9 * 9, 10)",
                  sizeX: 9,
                  sizeY: 9,
                  mineCount: 10,
                ),
                _NewGameButton(
                  difficulty: "Medium (16 * 16, 40)",
                  sizeX: 16,
                  sizeY: 16,
                  mineCount: 40,
                ),
                _NewGameButton(
                  difficulty: "Hard (30 * 16, 99)",
                  sizeX: 30,
                  sizeY: 16,
                  mineCount: 99,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _NewGameButton extends StatelessWidget {
  final String difficulty;
  final int sizeX;
  final int sizeY;
  final int mineCount;

  const _NewGameButton({
    required this.sizeX,
    required this.sizeY,
    required this.mineCount,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameView(
              sizeX: sizeX,
              sizeY: sizeY,
              mineCount: mineCount,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          difficulty,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
