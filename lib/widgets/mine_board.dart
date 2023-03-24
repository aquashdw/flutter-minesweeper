import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';
import 'package:minesweeper/service/mine_event.dart';
import 'package:minesweeper/service/mine_state.dart';
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
    var state = context.read<MineBloc>().state;
    var controlPadding = (65 - cellSize > 0 ? 65 - cellSize : 0).toDouble();
    var tapBefore = Timeline.now;
    var controlPosition = _controlPosition(
      state.controlX,
      state.controlY,
      countHorizontal,
      countVertical,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: cellSize * countHorizontal + controlPadding,
          height: cellSize * countVertical + controlPadding,
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
                              if (!(state.cellStateMap[i][j] ==
                                  CellState.blank)) {
                                if (Timeline.now - tapBefore < 300000 &&
                                    state.controlX == j && state.controlY == i) {
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
                              state.cellStateMap[i][j],
                              state.mineBoard[i][j],
                              Point(j, i),
                              state.controlStatus != ControlStatus.none &&
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
        state.controlStatus != ControlStatus.none
            ? Positioned(
                top: state.controlY * cellSize +
                    _controlOffsetY(state.controlY, controlPosition, cellSize,
                        controlPadding),
                left: state.controlX * cellSize +
                    _controlOffsetX(state.controlX, controlPosition, cellSize,
                        controlPadding),
                child: Controls(
                  position: controlPosition,
                  controlStatus: state.controlStatus,
                  cellSize: cellSize,
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  ControlPosition _controlPosition(int x, int y, int sizeX, int sizeY) {
    if (x > sizeX ~/ 2 - 1 && y > sizeY ~/ 2 - 1) {
      return ControlPosition.botRight;
    } else if (x > sizeX ~/ 2 - 1) {
      return ControlPosition.topRight;
    } else if (y > sizeY ~/ 2 - 1) {
      return ControlPosition.botLeft;
    } else {
      return ControlPosition.topLeft;
    }
  }

  double _controlOffsetX(int controlX, ControlPosition controlPosition,
      double cellSize, double controlPadding) {
    const offsetOn = {ControlPosition.topRight, ControlPosition.botRight};
    return offsetOn.contains(controlPosition) ? -cellSize - controlPadding : 0;
  }

  double _controlOffsetY(int controlY, ControlPosition controlPosition,
      double cellSize, double controlPadding) {
    const offsetOn = {ControlPosition.botLeft, ControlPosition.botRight};
    return offsetOn.contains(controlPosition) ? -cellSize - controlPadding : 0;
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
              ? Colors.greenAccent[100]
              : Colors.greenAccent[200],
          border: _setBorder(controlOpen),
        ),
        child: Center(
          child: Icon(
            Icons.flag,
            color: Colors.red,
            size: cellSize * 0.80,
          ),
        ),
      );
    } else if (cellState == CellState.flagWrong) {
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.flag,
                color: Colors.black,
                size: cellSize * 0.80,
              ),
              Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: cellSize * 0.80,
              ),
            ],
          ),
        ),
      );
    } else if (cellState == CellState.mine) {
      return Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: (cell.x + cell.y) % 2 == 0 ? Colors.red[600] : Colors.red[700],
          border: _setBorder(controlOpen),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Image.asset(
              "assets/icons8-mine.png",
              color: Colors.black,
            ),
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

  Widget? _fillChild(int cellValue) {
    if (cellValue == 9) {
      return Text(
        "X",
        style: TextStyle(
          fontSize: (cellSize ~/ 3 * 2).toDouble(),
          fontWeight: FontWeight.bold,
          color: Colors.red[900],
        ),
      );
    }
    if (0 < cellValue && cellValue < 9) {
      return Text(
        "$cellValue",
        style: TextStyle(
          fontSize: (cellSize ~/ 3 * 2).toDouble(),
          fontWeight: FontWeight.bold,
          color: _panelTextColor(cellValue),
        ),
      );
    }
    return null;
  }

  Color _panelTextColor(int cellValue) {
    switch (cellValue) {
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
