import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildRedIntensityChart(List<int> redSamples) {
  final spots = List.generate(
    redSamples.length,
    (i) => FlSpot(i.toDouble(), redSamples[i].toDouble()),
  );

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 255,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: spots,
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.3),
                          Colors.blueAccent.withOpacity(0.05)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    barWidth: 3,
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 500), // Animation on build
            ),
          ),
        );
      },
    ),
  );
}
