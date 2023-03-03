import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/service/mine_bloc.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.3),
      child: Center(
        child: Container(
          height: 250,
          width: 250,
          color: Colors.white,
          child: Column(
            children: [
              const Text("You Win!"),
              GestureDetector(
                onTap: () {
                  context.read<MineBloc>().add(CloseControlEvent());
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
