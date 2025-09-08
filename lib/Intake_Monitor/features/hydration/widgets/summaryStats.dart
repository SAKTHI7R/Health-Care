// daily_summary_widget.dart
import 'package:flutter/material.dart';
import '../../../blocs/water/water_state.dart';

class DailySummaryWidget extends StatelessWidget {
  final List<WaterLog> logs; // ← WaterLog
  final int goal; // goal in ml

  const DailySummaryWidget({required this.logs, required this.goal, super.key});

  @override
  Widget build(BuildContext context) {
    final total =
        logs.fold<int>(0, (sum, item) => sum + item.amountMl); // ← amountMl
    final average = logs.isEmpty ? 0 : (total / logs.length).round();
    final difference = goal - total;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("Total Intake: $total ml"),
            Text("Average per Session: $average ml"),
            Text(
              difference <= 0
                  ? "You met your goal! 🎉"
                  : "You're ${difference}ml away from your goal.",
              style: TextStyle(
                color: difference <= 0 ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
