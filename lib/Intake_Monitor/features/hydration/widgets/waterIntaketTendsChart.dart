import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WaterIntakeTrendsChart extends StatelessWidget {
  final List<int> dailyTotals; // 7 values: last 7 days
  final int goal; // goal in ml

  const WaterIntakeTrendsChart({
    Key? key,
    required this.dailyTotals,
    required this.goal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxY = [...dailyTotals.map((e) => e.toDouble()), goal.toDouble()]
            .reduce((a, b) => a > b ? a : b) +
        200;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                //tooltipBgColor: Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    "${_dayLabel(groupIndex)}\n${rod.toY.toInt()} ml",
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 500,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _dayLabel(value.toInt()),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 500,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: goal.toDouble(),
                color: Colors.blueAccent,
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.centerRight,
                  labelResolver: (_) => 'Goal: $goal ml',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ]),
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return dailyTotals.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.toDouble();
      final isToday = index == dailyTotals.length - 1;

      final color = isToday
          ? Colors.blueAccent
          : (value >= goal ? Colors.green : Colors.orange);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color.withOpacity(0.6),
                color,
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  String _dayLabel(int index) {
    final now = DateTime.now();
    final targetDate =
        now.subtract(Duration(days: dailyTotals.length - 1 - index));
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[targetDate.weekday % 7 == 0 ? 6 : targetDate.weekday - 1];
  }
}
