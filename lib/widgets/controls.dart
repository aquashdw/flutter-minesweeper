import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';

enum CellPosition { topLeft, topRight, botLeft, botRight }

class Controls extends StatelessWidget {
  final CellPosition position;
  final ControlStatus controlStatus;
  final int controlX;
  final int controlY;
  final double cellSize;

  const Controls({
    super.key,
    required this.position,
    required this.controlStatus,
    required this.cellSize,
    required this.controlX,
    required this.controlY,
  });

  @override
  Widget build(BuildContext context) {
    var sizeOver = (65 - cellSize) / 2;
    if (sizeOver < 0) sizeOver = 0;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 65,
            ),
            GestureDetector(
              onTap: () {
                context
                    .read<MineBloc>()
                    .add(ToggleFlagEvent(controlX, controlY));
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  border: Border.all(width: 4, color: Colors.blue),
                  borderRadius: BorderRadius.circular(32.5),
                  color: Colors.lightBlueAccent,
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                context.read<MineBloc>().add(OpenCellEvent(controlX, controlY));
              },
              child: Container(
                width: 65,
                height: 65,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 4, color: Colors.blue),
                  borderRadius: BorderRadius.circular(32.5),
                  color: Colors.lightBlueAccent,
                ),
                child: Image.asset(
                  "assets/flaticon-shovel.png",
                  color: Colors.blue[900],
                ),
              ),
            ),
            SizedBox(
              width: 65,
              height: 65,
              child: GestureDetector(
                onTap: () {
                  context.read<MineBloc>().add(CloseControlEvent());
                },
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.blue),
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.lightBlueAccent,
                    ),
                    child: const Center(
                      child: Text(
                        "X",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
