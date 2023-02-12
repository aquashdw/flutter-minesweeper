import 'package:flutter/material.dart';

enum CellPosition { topStart, topEnd, botStart, botEnd }

class Controls extends StatelessWidget {
  final CellPosition position;
  final double cellSize;

  const Controls({
    super.key,
    required this.position,
    required this.cellSize,
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
                print("tapped blue control");
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.5),
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                print("tapped red control");
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.5),
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(
              width: 65,
              height: 65,
              child: GestureDetector(
                onTap: () {
                  print("tapped green control");
                },
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    // Stack(
    //   clipBehavior: Clip.none,
    //   children: [
    //     Transform.translate(
    //       offset: Offset(65, -sizeOver),
    //       // left: 65,
    //       // top: -sizeOver,
    // child: GestureDetector(
    //   onTap: () {
    //     print("tapped blue control");
    //   },
    //   child: Container(
    //     width: 65,
    //     height: 65,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(32.5),
    //       color: Colors.blue,
    //     ),
    //   ),
    // ),
    //     ),
    //     Transform.translate(
    //       offset: Offset(-sizeOver, 65),
    // child: GestureDetector(
    //   behavior: HitTestBehavior.opaque,
    //   onTap: () {
    //     print("tapped red control");
    //   },
    //   child: Container(
    //     width: 65,
    //     height: 65,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(32.5),
    //       color: Colors.red,
    //     ),
    //   ),
    // ),
    // ),
    // Transform.translate(
    //   offset: const Offset(70, 70),
    //   child: GestureDetector(
    //     behavior: HitTestBehavior.translucent,
    //     onTap: () {
    //       print("tapped green control");
    //     },
    //     child: Container(
    //       width: 50,
    //       height: 50,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(22.5),
    //         color: Colors.green,
    //       ),
    //     ),
    //   ),
    // ),
    //   ],
    // );
  }
}
