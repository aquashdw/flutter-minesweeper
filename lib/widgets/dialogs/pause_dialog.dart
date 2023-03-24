import 'package:flutter/material.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    var dialogHeight = screenHeight / 3.5;
    var buttonWidth =
        (screenWidth - 40 > 230 ? 230 : screenWidth - 40).toDouble();
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
                    "Paused",
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
                      Navigator.pop(context);
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
                          "Resume",
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
