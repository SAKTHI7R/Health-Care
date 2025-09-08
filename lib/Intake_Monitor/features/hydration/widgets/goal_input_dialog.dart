//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../blocs/water/water_bloc.dart';
import '../../../blocs/water/water_event.dart';

class GoalInputWidget extends StatefulWidget {
  final String uid;
  const GoalInputWidget({required this.uid, Key? key}) : super(key: key);

  @override
  State<GoalInputWidget> createState() => _GoalInputWidgetState();
}

class _GoalInputWidgetState extends State<GoalInputWidget> {
  late int _selectedGoal;

  @override
  void initState() {
    super.initState();
    // Initialize _selectedGoal from the bloc’s current state:
    final currentGoal = context.read<InWaterBloc>().state.goalMl;
    _selectedGoal = currentGoal > 0 ? currentGoal : 2000;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Goal (ml)',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NumberPicker(
                    value: _selectedGoal,
                    minValue: 500,
                    maxValue: 5000,
                    step: 100,
                    haptics: true,
                    onChanged: (val) => setState(() => _selectedGoal = val),
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<InWaterBloc>()
                            .add(SetWaterGoalEvent(_selectedGoal));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Goal set to $_selectedGoal ml')),
                        );
                      },
                      child: Text('Save'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        context
                            .read<InWaterBloc>()
                            .add(ResetDailyIntakeEvent());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Goal reset to 0 ml')),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
