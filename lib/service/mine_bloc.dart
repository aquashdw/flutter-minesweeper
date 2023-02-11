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
      print('${event.x}, ${event.y}');
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

List<List<int>> generateBoard(horizontal, vertical, mineCount) {
  var countHorizontal = 6;
  var countVertical = 12;
  var mineCount = 10;
  var mineBoard = [
    for (var i = 0; i < countVertical; i++)
      [for (var j = 0; j < countHorizontal; j++) 0]
  ];
  var mineGen = Random();
  var minePositions = [];
  while (minePositions.length < mineCount) {
    var mineCandidate = mineGen.nextInt(countVertical * countHorizontal);
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
        if (!checkBounds(checkX, checkY, countHorizontal, countVertical)) {
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
