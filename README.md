# minesweeper

Minesweeper with Flutter (practice project)

Minesweeper is a puzzle game loved by many

## TODO

- lose
- win
- new game
- pause

## Minesweeper Logic

### open cell

first create the logic of what happens when the player tries to dig up a cell

- number => open
- mine => lose
- blank => open self and open surrounding cells
  
used simple bfs to open surroundings, its implemented in `mine_bloc.dart`

```dart
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
            // logically, there shouldn't be any mines
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
```

Used the `Point` object....just because.

### open cell multi

if enough flags are in place, we can open closed cells around number cells, but if there is a mine in one of the targets, then its game over.

so check ther surroundings with simple double loops, check bounds, and add them to a queue if its not a flag, open cell, or mine.

```dart
    for (var dx = -1; dx < 2; dx++) {
      for (var dy = -1; dy < 2; dy++) {
        var checkX = targetX + dx;
        var checkY = targetY + dy;
        // if in bounds
        if (checkBounds(checkX, checkY)) {
          // if flag
          if (cellStateMap[checkY][checkX] == CellState.flag) {
            // if flag is wrong
            if (mineBoard[checkY][checkX] != 9) {
              cellStateMap[checkY][checkX] = CellState.flagWrong;
            }
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

```

then call `openCell` for all cells in queue...if there is no mines. if there is a single mine in the surroundings, set them to mines.

```dart
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
```

## BLOC

now I have no idea how BLOC is used in real life, so just used my imaginations...

### MineState

a `State` is like the State of a stateful widget, so defined a `MineState` State object to hold the state of the game

```dart
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
  final int startTime;
  GameStatus status;

  MineState({
    required this.mineBoard,
    required this.cellStateMap,
    required this.mineCount,
    required this.sizeX,
    required this.sizeY,
    required this.startTime,
    this.controlStatus = ControlStatus.none,
    this.controlX = 0,
    this.controlY = 0,
    this.status = GameStatus.playing,
  });
  ...
```

`mineBoard` contains the raw data of a minesweeper game, its value correspond to

- `0`: blank, no mine in the surrounding 8 cells
- `1 ~ 8`: number, which indicates the count of mines in surrounding 8 cells
- `9`: mine.

thought about making a enum for this as well...but it would mean enum containing `0 ~ 9` so just used int

the `cellStateMap` is for actual display of the board, which cell is opened and which cell is flagged. which is required, as a puzzle game there is an answer to this puzzle, and the player's answer sheet in this game is the `cellStateMap`.

since its a state for use in BLOC, also created a method for shallow copy (with change if needed)

```dart
  ...
  MineState copyWith({
    ControlStatus? controlStatus,
    int? controlX,
    int? controlY,
    GameStatus? status,
  }) {
    return MineState(
      mineBoard: mineBoard,
      cellStateMap: cellStateMap,
      mineCount: mineCount,
      sizeX: sizeX,
      sizeY: sizeY,
      startTime: startTime,
      controlStatus: controlStatus ?? this.controlStatus,
      controlX: controlX ?? this.controlX,
      controlY: controlY ?? this.controlY,
      status: status ?? this.status,
    );
  }
  ...
```

### Events

`MineBloc` reacts to `MineEvent`s

```dart
abstract class MineEvent {}

...

class MineBloc extends Bloc<MineEvent, MineState> {
```

some events (like opening cells) require which cell was hit, so the `MineEvent` class is extended to `CellEvent`

```dart
class CellEvent extends MineEvent {
  final int x;
  final int y;

  CellEvent(this.x, this.y);
}
```

actual event handling is done within the state methods

```dart
class MineBloc extends Bloc<MineEvent, MineState> {
  MineBloc(MineState mineState) : super(mineState) {
    on<TapCellEvent>((event, emit) {
      emit(state.openControl(event.x, event.y));
    });
    on<ToggleFlagEvent>((event, emit) {
      emit(state.flagCell(event.x, event.y));
    });
    on<OpenCellMulitEvent>((event, emit) {
      emit(state.openCellMulti(event.x, event.y));
    });
    on<OpenCellEvent>((event, emit) {
      emit(state.openCell(event.x, event.y));
    });
    on<CloseControlEvent>((event, emit) {
      emit(state.closeControl());
    });
  }
}

...

class MineState {
  ...
    MineState flagCell(int x, int y) {
    var targetState = cellStateMap[y][x];
    if (targetState == CellState.closed || targetState == CellState.flag) {
      cellStateMap[y][x] =
          targetState == CellState.closed ? CellState.flag : CellState.closed;
      return copyWith(
        controlStatus: ControlStatus.none,
      );
    } else {
      return this;
    }
  }
  ...
}
```

hopefully the names will suffice for their functions

## User Interface

### GameView

used a `LayoutBuilder` to draw the screen

```dart
body: Container(
  color: Colors.lightBlue,
  child: SafeArea(
    child: Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          var sizeFromWidth = constraints.maxHeight * 0.9 / sizeY;
          var sizeFromHeight = constraints.maxWidth * 0.9 / sizeX;
          var panelSize = sizeFromHeight > sizeFromWidth
              ? sizeFromWidth
              : sizeFromHeight;
          var padddingSize = sizeFromHeight > sizeFromWidth
              ? constraints.maxHeight * 0.1
              : constraints.maxWidth * 0.1;
          return MineBoard(
            padddingSize: padddingSize,
            cellSize: panelSize,
            countHorizontal: sizeX,
            countVertical: sizeY,
          );
        },
      ),
    ),
  ),
),
```

for the cellSize(panelSize), divide each 90% of width and height of the constraint by count of horizontal cells and vertical cells, then use the one which is smaller. so the min padding will always be 10% of the constraint of the game screen.

the actual padding size is delivered to the child `MineBoard`, which does the actual drawing, which is required...

### MineBoard Widget

to keep the `MineBoard` widget a stateless widget, any variables that may change depending on state was calculated in the `BlocBuilder`'s `builder` argument

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<MineBloc, MineState>(
    builder: (context, state) {
      var controlPadding = (65 - cellSize > 0 ? 65 - cellSize : 0).toDouble();
      var tapBefore = Timeline.now;
      var controlPosition = _controlPosition(
        state.controlX,
        state.controlY,
        countHorizontal,
        countVertical,
      );
```

start with `Stack` to draw both the board and the controls

the board is actually a child of a `SizedBox` which is a little bigger than all the drawn cells

```dart
return Stack(
  clipBehavior: Clip.none,
  children: [
    SizedBox(
      width: cellSize * countHorizontal + controlPadding,
      height: cellSize * countVertical + controlPadding,
      ...
```

which was used because the controls can get off the board when the cell size is smaller than the control buttons, and once it get off the `Stack` the `GestureDetector` of the controls doesn't work

the `tapBefore` var is also included, because defining both the `onDoubleTap` and `onTap` of the `GestureDetector` (of cells) results in heavy delays


### Drawing the cells

just draw the cells with double collection-for loops

```dart
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

```

the several color variations are a pain in the ass, all implemented in dirty `if - else` statements

```dart
Widget? _drawCell(CellState cellState, int cellValue, Point cell, bool controlOpen) {
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
...
```

---

at the top of the stack there are the controls...

### Controls