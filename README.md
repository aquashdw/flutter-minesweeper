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
