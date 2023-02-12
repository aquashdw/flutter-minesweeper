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
          openCell(event.x, event.y, state.openState, state.mineBoard);
      emit(state.newOpenState(openState));
    });
    on<CloseControlEvent>((event, emit) {
      emit(state.closeControl());
    });
  }
}

enum GameStatus { playing, win, lose }

class MineState {
  final List<List<int>> mineBoard;
  final List<List<bool>> openState;
  final int sizeX;
  final int sizeY;
  final bool controlOpen;
  final int controlX;
  final int controlY;
  GameStatus status;

  MineState({
    required this.mineBoard,
    required this.openState,
    required this.sizeX,
    required this.sizeY,
    this.controlOpen = false,
    this.controlX = 0,
    this.controlY = 0,
    this.status = GameStatus.playing,
  });

  MineState newOpenState(List<List<bool>> openState) {
    return MineState(
      mineBoard: mineBoard,
      openState: openState,
      sizeX: sizeX,
      sizeY: sizeY,
      controlOpen: false,
    );
  }

  MineState openControl(int x, int y) {
    return MineState(
      mineBoard: mineBoard,
      openState: openState,
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
      openState: openState,
      sizeX: sizeX,
      sizeY: sizeY,
      controlOpen: false,
    );
  }
}

MineBloc newGame(int sizeX, int sizeY, int mineCount) {
  final openState = [
    for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) false]
  ];

  var mineState = MineState(
    mineBoard: generateBoard(sizeX, sizeY, mineCount),
    openState: openState,
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

List<List<bool>> openCell(int targetX, int targetY, List<List<bool>> openState,
    List<List<int>> mineBoard) {
  // is mine
  if (mineBoard[targetY][targetX] == 9) {
    openState[targetY][targetX] = true; // TODO lose
  }
  // mine in range
  else if (mineBoard[targetY][targetX] > 0) {
    openState[targetY][targetX] = true;
  }
  // mine not in range (open surrounding)
  else {
    var checkQueue = [Point(targetX, targetY)];
    var sizeX = openState[0].length;
    var sizeY = openState.length;
    var visited = [
      for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) false]
    ];
    while (checkQueue.isNotEmpty) {
      var next = checkQueue.removeAt(0);

      // open next cell
      openState[next.y][next.x] = true;
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
  return openState;
}
