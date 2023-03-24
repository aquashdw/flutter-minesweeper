import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';
import 'package:minesweeper/service/mine_event.dart';
import 'package:minesweeper/service/mine_state.dart';
import 'package:minesweeper/widgets/dialogs/pause_dialog.dart';
import 'package:minesweeper/widgets/dialogs/quit_confirm_dialog.dart';
import 'package:minesweeper/widgets/dialogs/win_dialog.dart';
import 'package:minesweeper/widgets/dialogs/lose_dialog.dart';

class DialogManager extends StatelessWidget {
  const DialogManager({super.key});

  @override
  Widget build(BuildContext context) {
    final mineBloc = context.read<MineBloc>();
    return BlocListener<MineBloc, MineState>(
      listener: ((context, state) {
        if (state.status == GameStatus.win) {
          showDialog(
            context: context,
            builder: (context) {
              return BlocProvider.value(
                value: mineBloc,
                child: const WinDialog(),
              );
            },
          );
        }
        if (state.status == GameStatus.lose) {
          showDialog(
            context: context,
            builder: (context) {
              return const LoseDialog();
            },
          );
        }
        if (state.status == GameStatus.tryQuit) {
          showDialog(
            context: context,
            builder: (context) {
              return const QuitConfirmDialog();
            },
          ).then((value) => value
              ? Navigator.pop(context)
              : context.read<MineBloc>().add(GameCancelQuitEvent()));
        }
        if (state.status == GameStatus.paused) {
          showDialog(
            context: context,
            builder: (context) {
              return const PauseDialog();
            },
          ).then(
              (value) => context.read<MineBloc>().add(GamePausePressEvent()));
        }
      }),
      child: Container(),
    );
  }
}
