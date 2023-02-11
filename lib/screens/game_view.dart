import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/mine_board.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MineSweeper"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.lightBlue,
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                var candidateWidth = constraints.maxHeight * 0.9 / 12;
                var candidateHeight = constraints.maxWidth * 0.9 / 6;
                var targetSize = candidateHeight > candidateWidth
                    ? candidateWidth
                    : candidateHeight;
                return SizedBox(
                  width: targetSize * 6,
                  height: targetSize * 12,
                  child: MineBoard(
                    panelSize: targetSize,
                    countHorizontal: 6,
                    countVertical: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
