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

void main(List<String> args) {
  var mineBoard = generateBoard(6, 12, 10);
  for (var row in mineBoard) {
    print(row);
  }
}
