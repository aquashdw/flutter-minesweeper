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

class GameStartEvent extends MineEvent {
  GameStartEvent();
}

class GamePausePressEvent extends MineEvent {
  GamePausePressEvent();
}

class GameTryQuitEvent extends MineEvent {
  GameTryQuitEvent();
}

class GameCancelQuitEvent extends MineEvent {
  GameCancelQuitEvent();
}

class TimerTickEvent extends MineEvent {
  TimerTickEvent();
}
