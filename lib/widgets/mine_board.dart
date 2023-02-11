import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';

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
    return BlocBuilder<MineBloc, MineState>(
      builder: (context, state) {
        return Column(
          children: [
            for (var i = 0; i < countVertical; i++)
              Row(
                children: [
                  for (var j = 0; j < countHorizontal; j++)
                    GestureDetector(
                      onTap: () {
                        context.read<MineBloc>().add(CellOpenEvent(j, i));
                      },
                      child: Container(
                        width: panelSize,
                        height: panelSize,
                        // color: (i + j) % 2 == 0
                        //     ? Colors.blueGrey[100]
                        //     : Colors.blueGrey[200],
                        color: state.openState[i][j]
                            ? Colors.amber
                            : (i + j) % 2 == 0
                                ? Colors.blueGrey[100]
                                : Colors.blueGrey[200],
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
