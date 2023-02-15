import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MineEvent {}

class CellEvent extends MineEvent {
  final int x;
  final int y;

  CellEvent(this.x, this.y);
}

class CloseControlEvent extends MineEvent {}

class ToggleFlagEvent extends CellEvent {
  ToggleFlagEvent(super.x, super.y);
}

class OpenCellEvent extends CellEvent {
  OpenCellEvent(super.x, super.y);
}

class OpenCellMulitEvent extends CellEvent {
  OpenCellMulitEvent(super.x, super.y);
}

class TapCellEvent extends CellEvent {
  TapCellEvent(super.x, super.y);
}

class MineBloc extends Bloc<MineEvent, MineState> {
  MineBloc(MineState mineState) : super(mineState) {
    on<TapCellEvent>((event, emit) {
      emit(state.openControl(event.x, event.y));
    });
    on<ToggleFlagEvent>((event, emit) {
      emit(state.flagCell(event.x, event.y));
    });
    on<OpenCellMulitEvent>((event, emit) {
      state.openCellMulti(event.x, event.y);
      emit(state.newState());
    });
    on<OpenCellEvent>((event, emit) {
      state.openCell(event.x, event.y);
      emit(state.newState());
    });
    on<CloseControlEvent>((event, emit) {
      emit(state.closeControl());
    });
  }
}

enum GameStatus { playing, win, lose }

enum CellState { closed, number, blank, flag, mine, flagWrong }

enum ControlStatus { none, all, shovel, flag }

class MineState {
  final List<List<int>> mineBoard;
  final List<List<CellState>> cellStateMap;
  final int mineCount;
  final int sizeX;
  final int sizeY;
  final ControlStatus controlStatus;
  final int controlX;
  final int controlY;
  GameStatus status;

  MineState({
    required this.mineBoard,
    required this.cellStateMap,
    required this.mineCount,
    required this.sizeX,
    required this.sizeY,
    this.controlStatus = ControlStatus.none,
    this.controlX = 0,
    this.controlY = 0,
    this.status = GameStatus.playing,
  });

  // shallow copy state
  MineState newState() {
    return MineState(
      mineBoard: mineBoard,
      cellStateMap: cellStateMap,
      mineCount: mineCount,
      sizeX: sizeX,
      sizeY: sizeY,
    );
  }

  MineState flagCell(int x, int y) {
    var targetState = cellStateMap[y][x];
    if (targetState == CellState.closed || targetState == CellState.flag) {
      cellStateMap[y][x] =
          targetState == CellState.closed ? CellState.flag : CellState.closed;
      return MineState(
        mineBoard: mineBoard,
        cellStateMap: cellStateMap,
        mineCount: mineCount,
        sizeX: sizeX,
        sizeY: sizeY,
        controlStatus: ControlStatus.none,
      );
    } else {
      return this;
    }
  }

  MineState openControl(int x, int y) {
    var controlStatus = ControlStatus.all;

    switch (cellStateMap[y][x]) {
      case CellState.blank:
        controlStatus = ControlStatus.none;
        break;
      case CellState.closed:
        controlStatus = ControlStatus.all;
        break;
      case CellState.flag:
        controlStatus = ControlStatus.flag;
        break;
      case CellState.number:
        var flagCount = 0;
        var blankCount = 0;
        for (var i = -1; i < 2; i++) {
          for (var j = -1; j < 2; j++) {
            if (checkBounds(x + j, y + i)) {
              if (cellStateMap[y + i][x + j] == CellState.flag) {
                flagCount += 1;
              } else if (cellStateMap[y + i][x + j] == CellState.closed) {
                blankCount += 1;
              }
            }
          }
        }
        controlStatus = flagCount == mineBoard[y][x] && blankCount > 0
            ? ControlStatus.shovel
            : ControlStatus.none;
        break;
      default:
        controlStatus = ControlStatus.all;
        break;
    }

    return MineState(
      mineBoard: mineBoard,
      cellStateMap: cellStateMap,
      mineCount: mineCount,
      sizeX: sizeX,
      sizeY: sizeY,
      controlStatus: controlStatus,
      controlX: x,
      controlY: y,
    );
  }

  MineState closeControl() {
    return MineState(
      mineBoard: mineBoard,
      cellStateMap: cellStateMap,
      mineCount: mineCount,
      sizeX: sizeX,
      sizeY: sizeY,
      controlStatus: ControlStatus.none,
    );
  }

  int mineLeft() {
    var count = 0;
    for (var row in cellStateMap) {
      for (var cell in row) {
        if (cell == CellState.flag) count += 1;
      }
    }
    return mineCount - count;
  }

  bool checkBounds(int targetX, int targetY) =>
      !(targetX < 0 || targetX >= sizeX || targetY < 0 || targetY >= sizeY);

  void openCell(int targetX, int targetY) {
    // is mine
    if (mineBoard[targetY][targetX] == 9) {
      // TODO lose
      cellStateMap[targetY][targetX] = CellState.mine;
    }
    // mine in range
    else if (mineBoard[targetY][targetX] > 0) {
      cellStateMap[targetY][targetX] = CellState.number;
    }
    // mine not in range (open surrounding)
    else {
      var checkQueue = [Point(targetX, targetY)];
      var visited = [
        for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) false]
      ];
      while (checkQueue.isNotEmpty) {
        var next = checkQueue.removeAt(0);
        // if visited continue
        if (visited[next.y][next.x]) continue;
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
        cellStateMap[next.y][next.x] = nextCellState;
        // set true to visited
        visited[next.y][next.x] = true;
        // if current cell is blank,
        if (mineBoard[next.y][next.x] == 0) {
          // check cells around you
          for (var dx = -1; dx < 2; dx++) {
            for (var dy = -1; dy < 2; dy++) {
              var checkX = next.x + dx;
              var checkY = next.y + dy;
              if (!checkBounds(checkX, checkY)) continue;
              if (visited[checkY][checkX]) continue;
              checkQueue.add(Point(checkX, checkY));
            }
          }
        }
      }
    }
  }

  void openCellMulti(int targetX, int targetY) {
    // queue for cells to open if no mines
    var checkQueue = <Point<int>>[];
    // queue for mines if mines behind surrounding cells
    var mines = <Point<int>>[];
    // for all surrounding cells
    for (var dx = -1; dx < 2; dx++) {
      for (var dy = -1; dy < 2; dy++) {
        var checkX = targetX + dx;
        var checkY = targetY + dy;
        // if in bounds
        if (checkBounds(checkX, checkY)) {
          // skip if flag
          if (cellStateMap[checkY][checkX] == CellState.flag) {
            continue;
          }
          // record mine
          else if (mineBoard[checkY][checkX] == 9) {
            mines.add(Point(checkX, checkY));
          }
          // record open
          else if (cellStateMap[checkY][checkX] == CellState.closed) {
            checkQueue.add(Point(checkX, checkY));
          }
        }
      }
    }

    // if any mines...
    if (mines.isNotEmpty) {
      // TODO lose
      for (var mine in mines) {
        cellStateMap[mine.y][mine.x] = CellState.mine;
      }
    }
    // if no mines
    else {
      // open all surrounding closed cells
      for (var check in checkQueue) {
        // cell may open in the progress, continue already open
        if (cellStateMap[check.y][check.x] != CellState.closed) continue;
        openCell(check.x, check.y);
      }
    }
  }
}

MineBloc newGame(int sizeX, int sizeY, int mineCount) {
  final cellState = [
    for (var i = 0; i < sizeY; i++)
      [for (var j = 0; j < sizeX; j++) CellState.closed]
  ];

  var mineState = MineState(
    mineBoard: generateBoard(sizeX, sizeY, mineCount),
    cellStateMap: cellState,
    mineCount: mineCount,
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
