import 'dart:developer';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'mine_event.dart';
import 'mine_state.dart';


class MineBloc extends Bloc<MineEvent, MineState> {
  MineBloc(MineState mineState) : super(mineState) {
    on<TapCellEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        emit(state.openControl(event.x, event.y));
      }
    });
    on<ToggleFlagEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        emit(state.flagCell(event.x, event.y));
      }
    });
    on<OpenCellMulitEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        emit(state.openCellMulti(event.x, event.y));
      }
    });
    on<OpenCellEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        emit(state.openCell(event.x, event.y));
      }
    });
    on<CloseControlEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        emit(state.closeControl());
      }
    });
  }
}

enum GameStatus { playing, win, lose }

enum CellState { closed, number, blank, flag, mine, flagWrong }

enum ControlStatus { none, all, shovel, flag }

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
    startTime: Timeline.now,
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
