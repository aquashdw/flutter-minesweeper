import 'package:flutter/material.dart';

class MineBoard extends StatelessWidget {
  final double panelSize;
  final int countHorizontal;
  final int countVertical;

  const MineBoard({
    super.key,
    required this.panelSize,
    required this.countHorizontal,
    required this.countVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < countVertical; i++)
          Row(
            children: [
              for (var j = 0; j < countHorizontal; j++)
                Container(
                  width: panelSize,
                  height: panelSize,
                  color: (i + j) % 2 == 0
                      ? Colors.blueGrey[100]
                      : Colors.blueGrey[200],
                ),
            ],
          ),
      ],
    );
  }
}
