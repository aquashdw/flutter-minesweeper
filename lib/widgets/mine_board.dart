import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';

class MineBoard extends StatelessWidget {
  final double padddingSize;
  final double panelSize;
  final int countHorizontal;
  final int countVertical;

  const MineBoard({
    super.key,
    required this.padddingSize,
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
                        context.read<MineBloc>().add(TapCellEvent(j, i));
                      },
                      onDoubleTap: () {
                        context.read<MineBloc>().add(OpenCellEvent(j, i));
                      },
                      child: state.openState[i][j]
                          ? Container(
                              width: panelSize,
                              height: panelSize,
                              decoration: BoxDecoration(
                                color: (i + j) % 2 == 0
                                    ? Colors.amber[100]
                                    : Colors.amber[200],
                                border: _setBorder(state.controlOpen &&
                                    state.controlX == j &&
                                    state.controlY == i),
                              ),
                              child: Center(
                                child: _fillChild(
                                  state.mineBoard[i][j],
                                ),
                              ),
                            )
                          : Container(
                              width: panelSize,
                              height: panelSize,
                              decoration: BoxDecoration(
                                color: (i + j) % 2 == 0
                                    ? Colors.blueGrey[100]
                                    : Colors.blueGrey[200],
                                border: _setBorder(
                                  state.controlOpen &&
                                      state.controlX == j &&
                                      state.controlY == i,
                                ),
                              ),
                            ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget? _fillChild(int state) {
    if (state == 9) {
      return Text(
        "X",
        style: TextStyle(
          fontSize: (panelSize ~/ 3 * 2).toDouble(),
          fontWeight: FontWeight.bold,
          color: Colors.red[900],
        ),
      );
      // return Icon(
      //   Icons.error_outline_sharp,
      //   size: (panelSize ~/ 3 * 2).toDouble(),
      // );
    }
    if (0 < state && state < 9) {
      return Text(
        "$state",
        style: TextStyle(
          fontSize: (panelSize ~/ 3 * 2).toDouble(),
          fontWeight: FontWeight.bold,
          color: _panelTextColor(state),
        ),
      );
    }
    return null;
  }

  Color _panelTextColor(int state) {
    switch (state) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return const Color(0xFF800000);
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Border? _setBorder(bool show) {
    if (show) {
      return Border.all(
        color: Colors.amber,
        width: 2,
      );
    }
    return null;
  }
}
