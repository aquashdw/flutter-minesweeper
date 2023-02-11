import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

void openCell(int targetX, int targetY, List<List<int>> maskedBoard,
    List<List<int>> mineBoard) {
  // is mine
  if (mineBoard[targetY][targetX] == 9) {
    // TODO: lose
    print("you lose!");
    exit(0);
  }
  // mine in range
  else if (mineBoard[targetY][targetX] > 0) {
    maskedBoard[targetY][targetX] = mineBoard[targetY][targetX];
  }
  // mine not in range (open multiple)
  else {
    var checkQueue = [Point(targetX, targetY)];
    var sizeX = maskedBoard[0].length;
    var sizeY = maskedBoard.length;
    var visited = [
      for (var i = 0; i < sizeY; i++) [for (var j = 0; j < sizeX; j++) false]
    ];
    while (checkQueue.isNotEmpty) {
      var next = checkQueue.removeAt(0);

      // open next cell
      maskedBoard[next.y][next.x] = mineBoard[next.y][next.x];
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
}

void flagCell(targetX, targetY, maskedBoard) {}

void printBoard(List<List<int>> mineBoard) {
  for (var row in mineBoard) {
    print(row);
  }
}

void main(List<String> args) {
  var mineBoard = generateBoard(6, 12, 10);
  printBoard(mineBoard);

  List<List<int>> maskedBoard = [
    for (var i = 0; i < 12; i++) [for (var j = 0; j < 6; j++) -1]
  ];
  while (true) {
    printBoard(maskedBoard);
    var line = stdin.readLineSync(encoding: utf8);
    var x = int.tryParse(line?.split(" ")[0] ?? "0") ?? 0;
    var y = int.tryParse(line?.split(" ")[1] ?? "0") ?? 0;

    openCell(x, y, maskedBoard, mineBoard);
  }
}
