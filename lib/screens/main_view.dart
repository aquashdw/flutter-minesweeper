import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/screens/game_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          var height = constraints.maxHeight;
          var width = constraints.maxWidth;
          // stack UI horizontally
          if (width * 5 >= height * 8) {
            return _HorizontalLayout(
              width: width,
              height: height,
            );
          }
          // stack UI vertically
          else {
            return _VerticalLayout(
              width: width,
              height: height,
            );
          }
        }),
      ),
    );
  }
}

class _VerticalLayout extends StatelessWidget {
  const _VerticalLayout({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    var mineSize = width < height ? width * 0.4 : height * 0.4;
    var fontSize = (height - mineSize) * 0.09;
    return Column(
      children: [
        Flexible(
          flex: 5,
          child: _MainBanner(
            fontSize: fontSize,
            mineSize: mineSize,
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
}

class _HorizontalLayout extends StatelessWidget {
  const _HorizontalLayout({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    var mineSize = width < height ? width * 0.65 : height * 0.65;
    var fontSize = height * 0.07;
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: _MainBanner(
            fontSize: fontSize,
            mineSize: mineSize,
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
                  difficulty: "Easy",
                  sizeX: 9,
                  sizeY: 9,
                  mineCount: 10,
                ),
                _NewGameButton(
                  difficulty: "Medium",
                  sizeX: 16,
                  sizeY: 16,
                  mineCount: 40,
                ),
                _NewGameButton(
                  difficulty: "Hard",
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

class _MainBanner extends StatelessWidget {
  const _MainBanner({
    required this.fontSize,
    required this.mineSize,
  });

  final double fontSize;
  final double mineSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.lightBlue),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "aquashdw's",
              style: TextStyle(
                fontSize: fontSize * 0.7,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _MineIcon(mineSize: mineSize),
            const SizedBox(
              height: 10,
            ),
            Text(
              "MineSweeper",
              style: TextStyle(
                fontSize: fontSize,
              ),
            )
          ],
        ),
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

class _MineIcon extends StatelessWidget {
  const _MineIcon({
    required this.mineSize,
  });

  final double mineSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: mineSize,
      height: mineSize,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: mineSize * 0.8,
              height: mineSize * 0.8,
              decoration: BoxDecoration(
                color: Colors.blueAccent[700],
                borderRadius: BorderRadius.circular(mineSize * 0.4),
              ),
            ),
          ),
          Center(
            child: Container(
              width: mineSize,
              height: mineSize * 0.1,
              decoration: BoxDecoration(
                color: Colors.blueAccent[700],
                borderRadius: BorderRadius.circular(mineSize * 0.05),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: pi * 0.25,
              child: Container(
                width: mineSize,
                height: mineSize * 0.1,
                decoration: BoxDecoration(
                  color: Colors.blueAccent[700],
                  borderRadius: BorderRadius.circular(mineSize * 0.05),
                ),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: -pi * 0.25,
              child: Container(
                width: mineSize,
                height: mineSize * 0.1,
                decoration: BoxDecoration(
                  color: Colors.blueAccent[700],
                  borderRadius: BorderRadius.circular(mineSize * 0.05),
                ),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: pi * 0.5,
              child: Container(
                width: mineSize,
                height: mineSize * 0.1,
                decoration: BoxDecoration(
                  color: Colors.blueAccent[700],
                  borderRadius: BorderRadius.circular(mineSize * 0.05),
                ),
              ),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: Offset(-mineSize * 0.1, -mineSize * 0.1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(mineSize * 0.1),
                ),
                width: mineSize * 0.2,
                height: mineSize * 0.2,
              ),
            ),
          )
        ],
      ),
    );
  }
}
