import 'package:flutter/material.dart';

class CalScreen extends StatefulWidget {
  const CalScreen({super.key});

  @override
  State<CalScreen> createState() => _CalScreenState();
}

class _CalScreenState extends State<CalScreen> {
  String displayValue = "0";
  List<String> operationSequence = []; // Stores the sequence of operations
  final isHighlightedOperator = ["÷", "x", "-", "+", "="];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth / 5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  key: ValueKey(displayValue),
                  child: Text(
                    displayValue,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            // Buttons
            Column(
              children: [
                buttonRow(["AC", "+/-", "%", "÷"], buttonSize),
                buttonRow(["7", "8", "9", "x"], buttonSize),
                buttonRow(["4", "5", "6", "-"], buttonSize),
                buttonRow(["1", "2", "3", "+"], buttonSize),
                buttonRow(["CAL", "0", ".", "="], buttonSize),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonRow(List<String> buttons, double buttonSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons.map((btn) {
          final isHighlighted = isHighlightedOperator.contains(btn);
          return circleButton(
            btn,
            buttonSize: buttonSize,
            color: isHighlighted ? Colors.orange : const Color(0xFF2B2B2D),
          );
        }).toList(),
      ),
    );
  }

  Widget circleButton(String text, {required double buttonSize, Color? color}) {
    return InkWell(
      splashFactory: InkSplash.splashFactory,
      onTap: () => handleInput(text),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color ?? Colors.black54,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(buttonSize / 2),
        ),
        child: Center(
          child: Builder(
            builder: (BuildContext context) {
              if (text == "CAL") {
                return const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.white,
                  size: 40,
                );
              } else if (text == "AC") {
                return const Icon(
                  Icons.backspace_rounded,
                  color: Colors.white,
                  size: 40,
                );
              }
              return Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 30),
              );
            },
          ),
        ),
      ),
    );
  }

  void handleInput(String input) {
    setState(() {
      if (input == "=") {
        performCalculation(); // Performs the calculation
      } else if (input == "AC") {
        if (operationSequence.isNotEmpty) {
          operationSequence.removeLast();
          displayValue = operationSequence.join("");
        }
      } else if (input == "CAL") {
        resetCalculator(); // Clears the calculator
      } else {
        appendNumber(input);
      }
    });
  }

  void resetCalculator() {
    displayValue = "0";
    operationSequence.clear();
  }

  void performCalculation() {
    if (operationSequence.isEmpty) {
      return;
    }

    if (isOperator(operationSequence.last)) {
      return;
    }

    double result = double.tryParse(operationSequence.first) ?? 0;

    for (int i = 1; i < operationSequence.length; i += 2) {
      String operator = operationSequence[i];
      double nextOperand = double.tryParse(operationSequence[i + 1]) ?? 0;

      switch (operator) {
        case "+":
          result += nextOperand;
          break;
        case "-":
          result -= nextOperand;
          break;
        case "x":
          result *= nextOperand;
          break;
        case "÷":
          if (nextOperand == 0) {
            displayValue = "Error";
            resetCalculator();
            return;
          }
          result /= nextOperand;
          break;
      }
    }

    displayValue = result.toString();
    if (displayValue.endsWith(".0")) {
      displayValue = displayValue.replaceAll(".0", "");
    }

    operationSequence.clear();
    operationSequence.add(displayValue);
  }

  void appendNumber(String number) {
    if (isOperator(number) && operationSequence.isEmpty) {
      return;
    }
    if (isOperator(number) && operationSequence.last == number) {
      return;
    }
    if (isOperator(number) && isOperator(operationSequence.last)) {
      operationSequence.removeLast();
    }
    // Show SnackBar for disabled operations
    if (number == "+/-" || number == "%" || number == ".") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This option is not available at this time."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    // Combine numbers if the last element is a number
    if (operationSequence.isNotEmpty &&
        !isOperator(operationSequence.last) &&
        !isOperator(number)) {
      number = operationSequence.last + number;
      operationSequence.removeLast();
    }
    operationSequence.add(number);
    displayValue = operationSequence.join("");
    print(operationSequence);
  }

  bool isOperator(String text) {
    return ["+", "-", "x", "÷"].contains(text);
  }
}
