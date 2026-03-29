import 'package:flutter/material.dart';

class PaintWordDisplay extends StatelessWidget {
  final bool myTurn;
  final String wordText;
  final int blanksCount;

  const PaintWordDisplay({
    super.key,
    required this.myTurn,
    required this.wordText,
    required this.blanksCount,
  });

  @override
  Widget build(BuildContext context) {
    if (myTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A4A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          wordText,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List<Widget>.generate(
        blanksCount,
        (index) => Container(
          width: 20,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFDCE5FF)),
          ),
        ),
      ),
    );
  }
}
