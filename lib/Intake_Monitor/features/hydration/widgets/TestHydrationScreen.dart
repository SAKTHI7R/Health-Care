/// The `TestHydrationScreen` class in Dart is a Flutter screen for tracking hydration levels,
/// displaying progress, setting goals, and showing intake history.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../blocs/water/water_bloc.dart';
import '../../../blocs/water/water_event.dart';
import '../../../blocs/water/water_state.dart';
import '../../../service/notification_service.dart';

class TestHydrationScreen extends StatefulWidget {
  final String userId;

  const TestHydrationScreen({super.key, required this.userId});

  @override
  State<TestHydrationScreen> createState() => _TestHydrationScreenState();
}

class _TestHydrationScreenState extends State<TestHydrationScreen> {
  late NotificationServiceIn _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationServiceIn(
      onIntakeLogged: (amount) {
        context.read<InWaterBloc>().add(AddWaterIntakeEvent(amount));
      },
    );
    Future.microtask(() {
      context.read<InWaterBloc>().add(FetchDailyIntakeEvent());
    });
    _notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Hydration Tracker"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<InWaterBloc, WaterState>(
          builder: (context, state) {
            double progress = state.goalMl > 0
                ? (state.currentIntakeMl / state.goalMl).clamp(0.0, 1.0)
                : 0.0;

            return SingleChildScrollView(
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 12.0,
                    percent: progress,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_drink,
                            size: 36, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          "${state.currentIntakeMl} ml",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.blue.shade100,
                    progressColor: Colors.blue,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                  ),
                  const SizedBox(height: 32),
                  _goalCard(state, progress),
                  const SizedBox(height: 20),
                  _mockIntakeHistory(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<InWaterBloc>()
                                .add(SetWaterGoalEvent(2000));
                          },
                          icon: const Icon(Icons.flag),
                          label: const Text("Set Goal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _notificationService.showInstantReminder(
                              state.currentIntakeMl,
                              state.goalMl,
                            );
                          },
                          icon: const Icon(Icons.notifications),
                          label: const Text("Test Notification"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<InWaterBloc>()
                            .add(AddWaterIntakeEvent(250));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Add 250 ml Water",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _goalCard(WaterState state, double progress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Goal",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Text("${state.goalMl} ml",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade100,
              color: Colors.blue,
              minHeight: 12,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text("${(progress * 100).toStringAsFixed(0)}%"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mockIntakeHistory() {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sun"];
    final values = [0.3, 0.5, 0.7, 0.9, 0.6, 0.4];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Water Intake History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(days.length, (index) {
                return Column(
                  children: [
                    Container(
                      width: 12,
                      height: 80 * values[index],
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[index], style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
