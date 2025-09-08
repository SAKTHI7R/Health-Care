import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care/Intake_Monitor/features/hydration/widgets/waterIntaketTendsChart.dart';

import '../../../blocs/water/water_bloc.dart';
//import '../../../blocs/water/water_event.dart';
import '../../../blocs/water/water_state.dart';
//import '../../../data/repositories/intake_repository.dart';

//import '../../../data/repositories/intake_repository.dart';
//import '../widgets/TestHydrationScreen.dart';
import '../widgets/goal_input_dialog.dart';
import '../widgets/intake_log_tile.dart';
import '../widgets/progress_circle.dart';
import '../widgets/reminder_settings.dart';
import '../widgets/summaryStats.dart';
//import '../widgets/trends_graph.dart';

class WaterDashboardScreen extends StatelessWidget {
  final String userId;
  const WaterDashboardScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Water Tracker'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReminderSettingsScreen()),
              ),
            ),
          ],
        ),
        body: BlocBuilder<InWaterBloc, WaterState>(
          builder: (context, state) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16), // Add padding here
                children: [
                  // Goal input
                  GoalInputWidget(uid: userId),
                  SizedBox(height: 16),

                  // Progress bar
                  IntakeProgressBar(
                    currentIntake: state.currentIntakeMl,
                    goalIntake: state.goalMl,
                  ),
                  SizedBox(height: 24),

                  // Daily Summary
                  DailySummaryWidget(
                    logs: state.intakeLogs,
                    goal: state.goalMl,
                  ),
                  SizedBox(height: 16),

                  // Intake Logs
                  IntakeLogWidget(
                    logs: state.intakeLogs,
                  ),
                  SizedBox(height: 24),

                  // Trends
                  WaterIntakeTrendsChart(
                    dailyTotals: state.intakeHistory.values.toList(),
                    goal: state.goalMl,
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        ));
  }
}
