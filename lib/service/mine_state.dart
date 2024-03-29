import 'dart:math';

class MineState {
  final List<List<int>> mineBoard;
  final List<List<CellState>> cellStateMap;
  final int mineCount;
  final int sizeX;
  final int sizeY;
  ControlStatus controlStatus;
  int controlX;
  int controlY;
  final int startTime;
  int elapsedTime;
  Point lastHit;
  GameStatus status;

  MineState({
    required this.mineBoard,
    required this.cellStateMap,
    required this.mineCount,
    required this.sizeX,
    required this.sizeY,
    required this.startTime,
    this.elapsedTime = 0,
    this.controlStatus = ControlStatus.none,
    this.controlX = 0,
    this.controlY = 0,
    this.lastHit = const Point(-1, -1),
    this.status = GameStatus.standby,
  });

  MineState copy() {
    return MineState(
      mineBoard: mineBoard,
      cellStateMap: cellStateMap,
      mineCount: mineCount,
      sizeX: sizeX,
      sizeY: sizeY,
      startTime: startTime,
      elapsedTime: elapsedTime,
      controlStatus: controlStatus,
      controlX: controlX,
      controlY: controlY,
      lastHit: Point(controlX, controlY),
      status: status,
    );
  }

  void flagCell(int x, int y) {
    var targetState = cellStateMap[y][x];
    if (targetState == CellState.closed || targetState == CellState.flag) {
      cellStateMap[y][x] =
          targetState == CellState.closed ? CellState.flag : CellState.closed;
      closeControl();
    }
  }

  void openControl(int x, int y) {
    lastHit = Point(x, y);
    controlX = x;
    controlY = y;

    switch (cellStateMap[y][x]) {
      case CellState.blank:
        controlStatus = ControlStatus.none;
        break;
      case CellState.closed:
        status == GameStatus.standby
            ? controlStatus = ControlStatus.shovel
            : controlStatus = ControlStatus.all;
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
      status = GameStatus.lose;
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

    _checkWin();
    _checkLose();
    closeControl();
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

    // if any mines...
    if (mines.isNotEmpty) {
      for (var mine in mines) {
        cellStateMap[mine.y][mine.x] = CellState.mine;
        status = GameStatus.lose;
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

    _checkWin();
    _checkLose();
    closeControl();
  }

  // set initial opening cell as blank cell
  void initBoard(int openX, int openY) {
    var mineGen = Random();
    var minePositions = [];
    var invalidPositions = [];

    // set points that cannot be mines
    // to be a blank cell, surroundings must also not be mines
    for (var dx = -1; dx < 2; dx++) {
      for (var dy = -1; dy < 2; dy++) {
        var checkX = openX + dx;
        var checkY = openY + dy;
        if (checkBounds(checkX, checkY)) {
          invalidPositions.add(Point(checkX, checkY));
        }
      }
    }

    // convert int to Point
    Point toPoint(int minePositionInt) {
      var mineX = minePositionInt % sizeX;
      var mineY = minePositionInt ~/ sizeX;
      return Point(mineX, mineY);
    }

    while (minePositions.length < mineCount) {
      var minePositionInt = mineGen.nextInt(sizeX * sizeY);
      var mineCandidate = toPoint(minePositionInt);
      // not already mine
      if (!minePositions.contains(mineCandidate) &&
          // not invalid position
          !invalidPositions.contains(mineCandidate)) {
        minePositions.add(mineCandidate);
      }
    }

    // set other numbers
    for (var minePosition in minePositions) {
      mineBoard[minePosition.y][minePosition.x] = 9;
      for (var dx = -1; dx < 2; dx++) {
        for (var dy = -1; dy < 2; dy++) {
          var checkX = minePosition.x + dx;
          var checkY = minePosition.y + dy;
          if (!checkBounds(checkX, checkY)) {
            continue;
          }
          if (mineBoard[checkY][checkX] != 9) {
            mineBoard[checkY][checkX]++;
          }
        }
      }
    }
  }

  void _checkWin() {
    var count = 0;
    for (var row in cellStateMap) {
      for (var cell in row) {
        if (cell == CellState.closed || cell == CellState.flag) count += 1;
      }
    }

    if (count == mineCount && status != GameStatus.lose) {
      status = GameStatus.win;
    }
  }

  void _checkLose() {
    if (status == GameStatus.lose) {
      for (var i = 0; i < sizeY; i++) {
        for (var j = 0; j < sizeX; j++) {
          if (cellStateMap[i][j] == CellState.closed && mineBoard[i][j] == 9) {
            cellStateMap[i][j] = CellState.mine;
          }
        }
      }
    }
  }

  void closeControl() {
    controlStatus = ControlStatus.none;
    controlX = -1;
    controlY = -1;
  }

  void tick() {
    elapsedTime = elapsedTime + 1;
  }

  void tryQuit() {
    status = GameStatus.tryQuit;
  }

  void cancelQuit(bool started) {
    status = started ? GameStatus.playing : GameStatus.standby;
  }

  void togglePause() {
    status =
        status == GameStatus.paused ? GameStatus.playing : GameStatus.paused;
  }
}

enum GameStatus { standby, playing, paused, win, lose, tryQuit }

enum CellState { closed, number, blank, flag, mine, flagWrong }

enum ControlStatus { none, all, shovel, flag }

class TimerTicker {
  const TimerTicker();

  Stream<void> tick() {
    return Stream.periodic(const Duration(seconds: 1));
  }
}
