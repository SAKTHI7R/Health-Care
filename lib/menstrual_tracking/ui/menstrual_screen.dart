import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/extensions/date_extensions.dart';
import 'package:lottie/lottie.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../bloc/menstrual_bloc.dart';
import '../bloc/menstrual_event.dart';
import '../bloc/menstrual_state.dart';
import '../data/models/cycle_model.dart';
import '../widget/addcycledialog.dart';

class MenstrualScreen extends StatefulWidget {
  const MenstrualScreen({super.key});

  @override
  State<MenstrualScreen> createState() => _MenstrualScreenState();
}

class _MenstrualScreenState extends State<MenstrualScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<MenstrualBloc>().add(LoadCycleData(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text(
          "Menstrual Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 4,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'reset') _confirmReset(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Cycle Data'),
              ),
            ],
          )
        ],
      ),
      body: BlocListener<MenstrualBloc, MenstrualState>(
        listener: (context, state) {
          if (state is MenstrualError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (_) => const AddCycleDialog(),
              );
            });
          }
          if (state is MenstrualLoaded) {
            final today = DateTime.now();
            final nextStartDate = state.nextStartDate;
            if (today
                    .isAfter(nextStartDate.subtract(const Duration(days: 1))) &&
                today.isBefore(nextStartDate.add(const Duration(days: 1)))) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cycle Prediction"),
                  content: Text(
                    "Your next cycle is predicted to start on ${nextStartDate.toShortDateString()}. Confirm?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                      ),
                      onPressed: () {
                        context.read<MenstrualBloc>().add(SaveCycleData(
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                              CycleModel(
                                startDate: nextStartDate,
                                endDate: nextStartDate.add(Duration(
                                    days: state.cycle.periodLength - 1)),
                                cycleLength: state.cycle.cycleLength,
                                periodLength: state.cycle.periodLength,
                              ),
                            ));
                        Navigator.pop(context);
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            }
          }
        },
        child: BlocBuilder<MenstrualBloc, MenstrualState>(
          builder: (context, state) {
            if (state is MenstrualLoading) {
              return Center(
                child: Lottie.asset('assets/loading.json', width: 150),
              );
            } else if (state is MenstrualLoaded) {
              final today = DateTime.now();
              final daysPassed =
                  today.difference(state.cycle.startDate).inDays + 1;
              final totalDays = state.stages.length;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerSection(state),
                    const SizedBox(height: 20),
                    _progressSection(daysPassed, totalDays),
                    const SizedBox(height: 20),
                    Expanded(child: _timelineSection(state)),
                  ],
                ),
              );
            } else if (state is MenstrualError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            } else {
              return const Center(child: Text("No cycle data available."));
            }
          },
        ),
      ),
    );
  }

  Widget _headerSection(MenstrualLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello Mam,",
          style: TextStyle(fontSize: 18, color: Colors.pinkAccent.shade200),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's your cycle overview",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _infoCard(Icons.calendar_today, "Start",
                  state.cycle.startDate.toShortDateString(), Colors.green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(Icons.calendar_month, "End",
                  state.cycle.endDate.toShortDateString(), Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _infoCard(Icons.refresh, "Next Start",
                    state.nextStartDate.toShortDateString(), Colors.blue)),
            const SizedBox(width: 10),
            Expanded(
                child: _infoCard(Icons.hourglass_bottom, "Next End",
                    state.nextEndDate.toShortDateString(), Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _progressSection(int daysPassed, int totalDays) {
    final double progress = (daysPassed / totalDays).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cycle Progress",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.pink.shade100,
          color: Colors.blueAccent,
          minHeight: 10,
          borderRadius: BorderRadius.circular(20),
        ),
        const SizedBox(height: 5),
        Text(
          "${(progress * 100).toStringAsFixed(0)}% Completed",
          style: const TextStyle(fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _timelineSection(MenstrualLoaded state) {
    final days = state.stages.entries.toList();
    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = state.cycle.startDate.add(Duration(days: index));
        final stageData = days[index].value;
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: index == 0,
          isLast: index == days.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 30,
            color: Colors.blue,
            iconStyle: IconStyle(iconData: Icons.favorite, color: Colors.white),
          ),
          beforeLineStyle: LineStyle(color: Colors.blueAccent, thickness: 3),
          endChild: Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(
                  "Day ${index + 1}: ${stageData['stage']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                subtitle: Text(
                  "${date.toShortDateString()}\nTip: ${stageData['tip']}",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(
      IconData icon, String title, String content, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Cycle"),
        content: const Text("Are you sure you want to reset your cycle data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                context.read<MenstrualBloc>().add(ResetCycleData(uid));
              }
              Navigator.pop(context);
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
