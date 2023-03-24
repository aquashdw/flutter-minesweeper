import 'package:flutter/material.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var dialogWidth = screenWidth * 0.9 > 640 ? 640.0 : screenWidth * 0.9;
    var dialogHeight = dialogWidth / 16 * 9;

    var buttonWidth =
        (screenWidth - 40 > 230 ? 230 : screenWidth - 40).toDouble();
    return Container(
      color: Colors.grey.withOpacity(0.3),
      child: Center(
        child: Container(
          height: dialogHeight,
          width: dialogWidth,
          color: Colors.lightBlue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    "You Win!",
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
                          "Close",
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
