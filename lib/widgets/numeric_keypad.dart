import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onOK;
  final String transferButtonText;
  final Color transferButtonColor;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onOK,
    this.transferButtonText = 'OK',
    this.transferButtonColor = const Color(0xFF8BC83D),
  });

  final double buttonHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildNumberRow(['1', '2', '3']),
              _buildNumberRow(['4', '5', '6']),
              _buildNumberRow(['7', '8', '9']),
              _buildNumberRow(['0', '.', '']),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(
              width: buttonHeight,
              height: buttonHeight,
              child: IconButton(
                icon: const Icon(Icons.backspace, color: Colors.black),
                onPressed: onBackspace,
              ),
            ),
            SizedBox(
              width: buttonHeight,
              height: 2 * buttonHeight,
              child: ElevatedButton(
                onPressed: onOK,
                style: ElevatedButton.styleFrom(
                  backgroundColor: transferButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  transferButtonText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> keys) {
    return SizedBox(
      height: buttonHeight,
      child: Row(
        children:
            keys.map((key) {
              if (key.isEmpty) return Expanded(child: Container());
              return Expanded(
                child: InkWell(
                  onTap: () => onKeyPressed(key),
                  child: Center(
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
