import 'package:flutter/material.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MineSweeper"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.lightBlue,
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  padding: const EdgeInsets.all(400),
                  color: Colors.red,
                  width: constraints.maxWidth * 0.9,
                  height: constraints.maxHeight * 0.9,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
