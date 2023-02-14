import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';
import 'package:minesweeper/widgets/controls.dart';

class MineBoard extends StatelessWidget {
  final double padddingSize;
  final double cellSize;
  final int countHorizontal;
  final int countVertical;

  const MineBoard({
    super.key,
    required this.padddingSize,
    required this.cellSize,
    required this.countHorizontal,
    required this.countVertical,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MineBloc, MineState>(
      builder: (context, state) {
        int tapBefore = Timeline.now;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: cellSize * countHorizontal + (65 - cellSize),
              height: cellSize * countVertical + (65 - cellSize),
              child: Center(
                child: SizedBox(
                  width: cellSize * countHorizontal,
                  height: cellSize * countVertical,
                  child: Column(
                    children: [
                      for (var i = 0; i < countVertical; i++)
                        Row(
                          children: [
                            for (var j = 0; j < countHorizontal; j++)
                              GestureDetector(
                                onTap: () {
                                  if (!(state.cellState[i][j] ==
                                      CellState.blank)) {
                                    if (Timeline.now - tapBefore < 300000) {
                                      context
                                          .read<MineBloc>()
                                          .add(OpenCellEvent(j, i));
                                    } else {
                                      tapBefore = Timeline.now;
                                      context
                                          .read<MineBloc>()
                                          .add(TapCellEvent(j, i));
                                    }
                                  } else {
                                    context
                                        .read<MineBloc>()
                                        .add(CloseControlEvent());
                                  }
                                },
                                behavior: HitTestBehavior.translucent,
                                child: _drawCell(
                                  state.cellState[i][j],
                                  state.mineBoard[i][j],
                                  Point(j, i),
                                  state.controlOpen &&
                                      state.controlX == j &&
                                      state.controlY == i,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            state.controlOpen
                ? Positioned(
                    top: state.controlY * cellSize,
                    left: state.controlX * cellSize,
                    child: Controls(
                      position: CellPosition.topStart,
                      controlX: state.controlX,
                      controlY: state.controlY,
                      cellSize: cellSize,
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }

  Widget? _drawCell(
      CellState cellState, int cellValue, Point cell, bool controlOpen) {
    if (cellState == CellState.closed) {
      return Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: (cell.x + cell.y) % 2 == 0
              ? Colors.blueGrey[100]
              : Colors.blueGrey[200],
          border: _setBorder(controlOpen),
        ),
      );
    } else if (cellState == CellState.flag) {
      return Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: (cell.x + cell.y) % 2 == 0
              ? Colors.blueGrey[100]
              : Colors.blueGrey[200],
          border: _setBorder(controlOpen),
        ),
        child: Center(
          child: Icon(
            Icons.flag,
            color: Colors.red,
            size: (cellSize ~/ 3 * 2).toDouble(),
          ),
        ),
      );
    } else {
      return Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: (cell.x + cell.y) % 2 == 0
              ? Colors.amber[100]
              : Colors.amber[200],
          border: _setBorder(controlOpen),
        ),
        child: Center(
          child: _fillChild(
            cellValue,
          ),
        ),
      );
    }
  }

  Widget? _fillChild(int state) {
    if (state == 9) {
      return Text(
        "X",
        style: TextStyle(
          fontSize: (cellSize ~/ 3 * 2).toDouble(),
          fontWeight: FontWeight.bold,
          color: Colors.red[900],
        ),
      );
    }
    if (0 < state && state < 9) {
      return Text(
        "$state",
        style: TextStyle(
          fontSize: (cellSize ~/ 3 * 2).toDouble(),
          fontWeight: FontWeight.bold,
          color: _panelTextColor(state),
        ),
      );
    }
    return null;
  }

  Color _panelTextColor(int state) {
    switch (state) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return const Color(0xFF800000);
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Border? _setBorder(bool show) {
    if (show) {
      return Border.all(
        color: Colors.amber,
        width: 2,
      );
    }
    return null;
  }
}
