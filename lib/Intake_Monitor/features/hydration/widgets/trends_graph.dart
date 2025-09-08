import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care/Intake_Monitor/blocs/water/water_bloc.dart';
import 'package:health_care/Intake_Monitor/blocs/water/water_event.dart';
import 'package:health_care/Intake_Monitor/blocs/water/water_state.dart';
import 'package:health_care/Intake_Monitor/features/hydration/widgets/waterIntaketTendsChart.dart';

class WaterTrendsScreen extends StatefulWidget {
  final int goal;
  const WaterTrendsScreen({super.key, required this.goal});

  @override
  State<WaterTrendsScreen> createState() => _WaterTrendsScreenState();
}

class _WaterTrendsScreenState extends State<WaterTrendsScreen> {
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final end = DateTime(now.year, now.month, now.day);

    // Trigger fetching intake history from BLoC
    context.read<InWaterBloc>().add(FetchIntakeHistoryEvent(start, end));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Trends'),
      ),
      body: BlocBuilder<InWaterBloc, WaterState>(builder: (context, state) {
        // Use BLoC state's intakeHistory directly
        final dailyTotals = _getLast7DaysTotals(
            state.intakeHistory.cast<DateTime, List<WaterLog>>());

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Last 7 Days Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: WaterIntakeTrendsChart(
                  dailyTotals: dailyTotals,
                  goal: widget.goal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<int> _getLast7DaysTotals(Map<DateTime, List<WaterLog>> history) {
    final now = DateTime.now();
    final totals = <int>[];

    for (int i = 6; i >= 0; i--) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final logs = history.entries
          .firstWhere(
            (entry) => _isSameDay(entry.key, day),
            orElse: () => MapEntry(day, []),
          )
          .value;

      final total = logs.fold(0, (sum, log) => sum + log.amountMl);
      totals.add(total);
    }
    return totals;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
