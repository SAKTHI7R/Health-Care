import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../repository/hydration_repository.dart';

class WaterChart extends StatelessWidget {
  const WaterChart({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<WaterRepository>(); // Access the repository

    return StreamBuilder<QuerySnapshot>(
      stream: repository
          .getTodayLogsStream(), // Get today's water intake logs stream
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        final Map<String, int> dailyTotals = {};

        for (var log in logs) {
          final date = (log['timestamp'] as Timestamp).toDate();
          final key = DateFormat('EEE').format(date); // Get the day of the week
          dailyTotals[key] = (dailyTotals[key] ?? 0) +
              (log['ml'] as int); // Accumulate water intake per day
        }

        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final data = days.map((day) => dailyTotals[day] ?? 0).toList();

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 3000, // Set a max Y value for the chart
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    return Text(days[index % 7],
                        style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
            ),
            barGroups: data.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.toDouble(),
                    width: 14,
                    color: Colors.blue,
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
