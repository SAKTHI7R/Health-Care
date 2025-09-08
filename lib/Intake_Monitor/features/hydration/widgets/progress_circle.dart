import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class IntakeProgressBar extends StatelessWidget {
  final int currentIntake; // in ml
  final int goalIntake; // in ml

  const IntakeProgressBar({
    required this.currentIntake,
    required this.goalIntake,
    super.key,
  });

  Color _getProgressColor(double percent) {
    if (percent < 0.4) return Colors.redAccent;
    if (percent < 0.7) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final double percent = (currentIntake / goalIntake).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 20.0,
      animation: true,
      percent: percent,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$currentIntake / $goalIntake ml",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "${(percent * 100).toStringAsFixed(0)}%",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.grey.shade200,
      progressColor: _getProgressColor(percent),
    );
  }
}
