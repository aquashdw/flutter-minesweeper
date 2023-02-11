import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MineEvent {}

class CellOpenEvent extends MineEvent {
  final int x;
  final int y;

  CellOpenEvent(this.x, this.y);
}

class MineBloc extends Bloc<MineEvent, MineState> {
  // bloc holds its state
  MineBloc(MineState mineState) : super(mineState) {
    on<CellOpenEvent>((event, emit) {
      // print('${event.x}, ${event.y}');

      var openState =
          openCell(event.x, event.y, state.openState, state.mineBoard);
      emit(state.newOpenState(openState));
    });
  }
}

enum GameStatus { playing, win, lose }

class MineState {
  final List<List<int>> mineBoard;
  final List<List<bool>> openState;
  final int sizeX;
  final int sizeY;
  GameStatus status;

  MineState({
    required this.mineBoard,
    required this.openState,
    required this.sizeX,
    required this.sizeY,
    this.status = GameStatus.playing,
  });

  MineState newOpenState(List<List<bool>> openState) {
    return MineState(
      mineBoard: mineBoard,
      openState: openState,
      sizeX: sizeX,
      sizeY: sizeY,
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
    var mineX = minePosition % 6;
    var mineY = minePosition ~/ 6;
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
            checkQueue.add(Point(checkX, checkY));
          }
        }
      }
    }
  }
  return openState;
}
