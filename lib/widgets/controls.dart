import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';

// where the target cell will be positioned
enum ControlPosition { topLeft, topRight, botLeft, botRight }

class Controls extends StatelessWidget {
  final ControlPosition position;
  final ControlStatus controlStatus;
  final int positionX;
  final int positionY;
  final double cellSize;

  static const reverseColOn = {
    ControlPosition.botLeft,
    ControlPosition.botRight,
  };
  static const reverseRowOn = {
    ControlPosition.topRight,
    ControlPosition.botRight,
  };

  static const showFlagOn = {
    ControlStatus.all,
    ControlStatus.flag,
  };
  static const showShovelOn = {
    ControlStatus.all,
    ControlStatus.shovel,
  };

  const Controls({
    super.key,
    required this.position,
    required this.controlStatus,
    required this.cellSize,
    required this.positionX,
    required this.positionY,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MineBloc, MineState>(
      builder: (context, state) {
        return Column(
          children: reverseColOn.contains(position)
              ? columnChildren(context, state).reversed.toList()
              : columnChildren(context, state),
        );
      },
    );
  }

  List<Widget> columnChildren(BuildContext context, MineState state) {
    return [
      Row(
        children: reverseRowOn.contains(position)
            ? _topControls(context, state).reversed.toList()
            : _topControls(context, state),
      ),
      Row(
        children: reverseRowOn.contains(position)
            ? _botControls(context, state).reversed.toList()
            : _botControls(context, state),
      ),
    ];
  }

  List<Widget> _topControls(BuildContext context, MineState state) {
    return [
      const SizedBox(
        width: 65,
      ),
      GestureDetector(
        onTap: () {
          context
              .read<MineBloc>()
              .add(ToggleFlagEvent(state.controlX, state.controlY));
        },
        child: showFlagOn.contains(controlStatus)
            ? Container(
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
              )
            : const SizedBox(
                width: 65,
                height: 65,
              ),
      ),
    ];
  }

  List<Widget> _botControls(BuildContext context, MineState state) {
    return [
      GestureDetector(
        onTap: () {
          switch (controlStatus) {
            case ControlStatus.shovel:
              context
                  .read<MineBloc>()
                  .add(OpenCellMulitEvent(state.controlX, state.controlY));
              break;
            case ControlStatus.all:
              context
                  .read<MineBloc>()
                  .add(OpenCellEvent(state.controlX, state.controlY));
              break;
            default:
              break;
          }
        },
        child: showShovelOn.contains(controlStatus)
            ? Container(
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
              )
            : const SizedBox(
                width: 65,
                height: 65,
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
    ];
  }
}
