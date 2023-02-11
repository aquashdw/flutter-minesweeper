import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';
import 'package:minesweeper/widgets/mine_board.dart';

class GameView extends StatelessWidget {
  final int sizeX;
  final int sizeY;
  final int mineCount;

  const GameView({
    super.key,
    required this.sizeX,
    required this.sizeY,
    required this.mineCount,
  });

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
                var candidateWidth = constraints.maxHeight * 0.9 / sizeY;
                var candidateHeight = constraints.maxWidth * 0.9 / sizeX;
                var targetSize = candidateHeight > candidateWidth
                    ? candidateWidth
                    : candidateHeight;
                return SizedBox(
                  width: targetSize * 6,
                  height: targetSize * 12,
                  child: BlocProvider<MineBloc>(
                    create: (context) => newGame(sizeX, sizeY, mineCount),
                    child: MineBoard(
                      panelSize: targetSize,
                      countHorizontal: 6,
                      countVertical: 12,
                    ),
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
