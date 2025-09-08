import 'package:flutter/material.dart';

class HeartRateGraph extends StatelessWidget {
  final List<int> redValues;
  final List<int> bpmHistory;

  HeartRateGraph({required this.redValues, required this.bpmHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: CustomPaint(
        painter: GraphPainter(redValues, bpmHistory),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<int> redValues;
  final List<int> bpmHistory;

  GraphPainter(this.redValues, this.bpmHistory);

  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()..color = Colors.red;
    final bpmPaint = Paint()..color = Colors.blue;
    double width = size.width /
        (redValues.length > bpmHistory.length
            ? redValues.length
            : bpmHistory.length);

    for (int i = 0; i < redValues.length - 1; i++) {
      canvas.drawLine(
        Offset(i * width, size.height - redValues[i].toDouble()),
        Offset((i + 1) * width, size.height - redValues[i + 1].toDouble()),
        redPaint,
      );
    }

    for (int i = 0; i < bpmHistory.length - 1; i++) {
      canvas.drawLine(
        Offset(i * width, size.height - bpmHistory[i].toDouble()),
        Offset((i + 1) * width, size.height - bpmHistory[i + 1].toDouble()),
        bpmPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
