import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MineEvent {}

class CellEvent extends MineEvent {
  final int x;
  final int y;

  CellEvent(this.x, this.y);
}

class CloseControlEvent extends MineEvent {}

class OpenCellEvent extends CellEvent {
  OpenCellEvent(super.x, super.y);
}

class TapCellEvent extends CellEvent {
  TapCellEvent(super.x, super.y);
}

class MineBloc extends Bloc<MineEvent, MineState> {
  MineBloc(MineState mineState) : super(mineState) {
    on<TapCellEvent>((event, emit) {
      emit(state.openControl(event.x, event.y));
    });
    on<OpenCellEvent>((event, emit) {
      var openState =
          openCell(event.x, event.y, state.cellState, state.mineBoard);
      emit(state.newOpenState(openState));
    });
    on<CloseControlEvent>((event, emit) {
      emit(state.closeControl());
    });
  }
}

enum GameStatus { playing, win, lose }

enum CellState { closed, number, blank, flag, mine }

class MineState {
  final List<List<int>> mineBoard;
  final List<List<CellState>> cellState;
  final int sizeX;
  final int sizeY;
  final bool controlOpen;
  final int controlX;
  final int controlY;
  GameStatus status;

  MineState({
    required this.mineBoard,
    required this.cellState,
    required this.sizeX,
    required this.sizeY,
    this.controlOpen = false,
    this.controlX = 0,
    this.controlY = 0,
    this.status = GameStatus.playing,
  });

  MineState newOpenState(List<List<CellState>> cellState) {
    return MineState(
      mineBoard: mineBoard,
      cellState: cellState,
      sizeX: sizeX,
      sizeY: sizeY,
      controlOpen: false,
    );
  }

  MineState openControl(int x, int y) {
    return MineState(
      mineBoard: mineBoard,
      cellState: cellState,
      sizeX: sizeX,
      sizeY: sizeY,
      controlOpen: true,
      controlX: x,
      controlY: y,
    );
  }

  MineState closeControl() {
    return MineState(
      mineBoard: mineBoard,
      cellState: cellState,
      sizeX: sizeX,
      sizeY: sizeY,
      controlOpen: false,
    );
  }
}

MineBloc newGame(int sizeX, int sizeY, int mineCount) {
  final cellState = [
    for (var i = 0; i < sizeY; i++)
      [for (var j = 0; j < sizeX; j++) CellState.closed]
  ];

  var mineState = MineState(
    mineBoard: generateBoard(sizeX, sizeY, mineCount),
    cellState: cellState,
    sizeX: sizeX,
    sizeY: sizeY,
  );
  return MineBloc(mineState);
}

bool checkBounds(int targetX, int targetY, int sizeX, int sizeY) {
  return !(targetX < 0 || targetX >= sizeX || targetY < 0 || targetY >= sizeY);
}

List<List<int>> generateBoard(sizeX, sizeY, mineCount) {
  var mineBoard = [
    for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) 0]
  ];
  var mineGen = Random();
  var minePositions = [];
  while (minePositions.length < mineCount) {
    var mineCandidate = mineGen.nextInt(sizeX * sizeY);
    if (!minePositions.contains(mineCandidate)) {
      minePositions.add(mineCandidate);
    }
  }

  for (var minePosition in minePositions) {
    var mineX = minePosition % sizeX;
    var mineY = minePosition ~/ sizeX;
    mineBoard[mineY][mineX] = 9;
    for (var dx = -1; dx < 2; dx++) {
      for (var dy = -1; dy < 2; dy++) {
        var checkX = mineX + dx;
        var checkY = mineY + dy;
        if (!checkBounds(checkX, checkY, sizeX, sizeY)) {
          continue;
        }
        if (mineBoard[checkY][checkX] != 9) {
          mineBoard[checkY][checkX]++;
        }
      }
    }
  }

  return mineBoard;
}

List<List<CellState>> openCell(int targetX, int targetY,
    List<List<CellState>> cellState, List<List<int>> mineBoard) {
  // is mine
  if (mineBoard[targetY][targetX] == 9) {
    cellState[targetY][targetX] = CellState.mine; // TODO lose
  }
  // mine in range
  else if (mineBoard[targetY][targetX] > 0) {
    cellState[targetY][targetX] = CellState.number;
  }
  // mine not in range (open surrounding)
  else {
    var checkQueue = [Point(targetX, targetY)];
    var sizeX = cellState[0].length;
    var sizeY = cellState.length;
    var visited = [
      for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) false]
    ];
    while (checkQueue.isNotEmpty) {
      var next = checkQueue.removeAt(0);
      var nextCell = mineBoard[next.y][next.x];
      var nextCellState = (cell) {
        if (cell == 0) {
          return CellState.blank;
        } else if (0 < cell && cell < 9) {
          return CellState.number;
        } else {
          throw Error();
        }
      }(nextCell);
      // open next cell
      cellState[next.y][next.x] = nextCellState;
      // set true to visited
      visited[next.y][next.x] = true;
      // if current cell is blank,
      if (mineBoard[next.y][next.x] == 0) {
        // check cells around you
        for (var dx = -1; dx < 2; dx++) {
          for (var dy = -1; dy < 2; dy++) {
            var checkX = next.x + dx;
            var checkY = next.y + dy;
            if (!checkBounds(checkX, checkY, sizeX, sizeY)) continue;
            if (visited[checkY][checkX]) continue;
            // add the cell to visit next
            if (!checkQueue.contains(Point(checkX, checkY))) {
              checkQueue.add(Point(checkX, checkY));
            }
          }
        }
      }
    }
  }
  return cellState;
}
