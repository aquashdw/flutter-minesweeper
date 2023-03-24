import 'package:flutter/material.dart';

class QuitConfirmDialog extends StatelessWidget {
  const QuitConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    var dialogHeight = screenHeight / 3.5;
    var buttonWidth =
        ((screenWidth - 60) ~/ 2 > 230 ? 230 : (screenWidth - 60) ~/ 2)
            .toDouble();
    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: Container(
          height: dialogHeight,
          color: Colors.lightBlue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    "Quit and return to menu?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(),
                      ),
                      width: buttonWidth,
                      height: 50,
                      child: const Center(
                        child: Text(
                          "Quit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(),
                      ),
                      width: buttonWidth,
                      height: 50,
                      child: const Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
