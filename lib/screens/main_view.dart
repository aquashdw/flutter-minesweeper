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
                      vertical: height * 0.3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        _NewGameButton(
                          difficulty: "Easy",
                          sizeX: 8,
                          sizeY: 16,
                          mineCount: 10,
                        ),
                        _NewGameButton(
                          difficulty: "Medium",
                          sizeX: 10,
                          sizeY: 18,
                          mineCount: 35,
                        ),
                        _NewGameButton(
                          difficulty: "Hard",
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
          // stack UI vertically
          else {}
          return const Center(
            child: Text("Test"),
          );
        }),
      ),
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
