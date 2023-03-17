import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';
import 'package:minesweeper/service/mine_state.dart';
import 'package:minesweeper/widgets/dialog_manager.dart';
import 'package:minesweeper/widgets/mine_board.dart';

class GameView extends StatelessWidget {
  final int sizeX;
  final int sizeY;
  final int mineCount;

  const GameView({
    super.key,
    required this.sizeX,
    required this.sizeY,
    required this.mineCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MineBloc>(
      create: (context) => newGame(sizeX, sizeY, mineCount),
      child: BlocBuilder<MineBloc, MineState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blueAccent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flag,
                        color: Colors.red,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text("${state.mineLeft()}"),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.alarm,
                        color: Colors.amber,
                        size: 30,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      _TimeDisplay(),
                    ],
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                const DialogManager(),
                Container(
                  color: Colors.lightBlue,
                  child: SafeArea(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          var sizeFromWidth =
                              constraints.maxHeight * 0.9 / sizeY;
                          var sizeFromHeight =
                              constraints.maxWidth * 0.9 / sizeX;
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
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimeDisplay extends StatefulWidget {
  const _TimeDisplay();

  @override
  State<_TimeDisplay> createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<_TimeDisplay> {
  late final Timer timer;
  int now = Timeline.now;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 500), tick);
    super.initState();
  }

  void tick(Timer timer) {
    setState(() {
      now = Timeline.now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${Duration(microseconds: now - context.read<MineBloc>().state.startTime).inSeconds}",
    );
  }
}
