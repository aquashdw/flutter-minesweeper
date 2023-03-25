import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'mine_event.dart';
import 'mine_state.dart';

class MineBloc extends Bloc<MineEvent, MineState> {
  MineBloc({required MineState mineState})
      : _ticker = const TimerTicker(),
        super(mineState) {
    on<GameStartEvent>((event, emit) {
      _tickerSubscription?.cancel();
      _tickerSubscription =
          _ticker.tick().listen((event) => add(TimerTickEvent()));
    });
    on<TapCellEvent>((event, emit) {
      const openOnStatus = [GameStatus.playing, GameStatus.standby];
      if (openOnStatus.contains(state.status)) {
        state.openControl(event.x, event.y);
        emit(state.copy());
      }
    });
    on<ToggleFlagEvent>((event, emit) {
      if (state.status == GameStatus.standby) {
        add(GameStartEvent());
        state.status = GameStatus.playing;
      }
      if (state.status == GameStatus.playing) {
        state.flagCell(event.x, event.y);
        emit(state.copy());
      }
    });
    on<OpenCellMulitEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        state.openCellMulti(event.x, event.y);
        emit(state.copy());
      }
    });
    on<OpenCellEvent>((event, emit) {
      if (state.status == GameStatus.standby) {
        add(GameStartEvent());
        state.initBoard(event.x, event.y);
        state.status = GameStatus.playing;
      }
      if (state.status == GameStatus.playing) {
        state.openCell(event.x, event.y);
        emit(state.copy());
      }
    });
    on<CloseControlEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        state.closeControl();
        emit(state.copy());
      }
    });
    on<TimerTickEvent>((event, emit) {
      if (state.status == GameStatus.playing) {
        state.tick();
        emit(state.copy());
      }
    });
    on<GameTryQuitEvent>((event, emit) {
      state.tryQuit();
      emit(state.copy());
    });
    on<GameCancelQuitEvent>((event, emit) {
      state.cancelQuit();
      emit(state.copy());
    });
    on<GamePausePressEvent>((event, emit) {
      const targetStatus = [GameStatus.playing, GameStatus.paused];
      if (targetStatus.contains(state.status)) {
        state.togglePause();
        emit(state.copy());
      }
    });
  }

  final TimerTicker _ticker;
  StreamSubscription<void>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}

MineBloc newGame(int sizeX, int sizeY, int mineCount) {
  final cellState = [
    for (var i = 0; i < sizeY; i++)
      [for (var j = 0; j < sizeX; j++) CellState.closed]
  ];

  var mineState = MineState(
    // mineBoard: generateBoard(sizeX, sizeY, mineCount),
    mineBoard: [
      for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) 0]
    ],
    cellStateMap: cellState,
    mineCount: mineCount,
    sizeX: sizeX,
    sizeY: sizeY,
    startTime: Timeline.now,
  );
  return MineBloc(mineState: mineState);
}

bool checkBounds(int targetX, int targetY, int sizeX, int sizeY) {
  return !(targetX < 0 || targetX >= sizeX || targetY < 0 || targetY >= sizeY);
}
