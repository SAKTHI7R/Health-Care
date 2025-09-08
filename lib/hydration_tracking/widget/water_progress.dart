import 'package:flutter/material.dart';

class WaterProgress extends StatelessWidget {
  final double percent;
  const WaterProgress({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 12,
                backgroundColor: Colors.blue.shade100,
              ),
            ),
            Text("${(percent * 100).round()}%", style: TextStyle(fontSize: 24))
          ],
        )
      ],
    );
  }
}
