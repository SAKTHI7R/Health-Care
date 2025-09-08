// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/reminder/reminder_bloc.dart';
import '../../../blocs/reminder/reminder_event.dart';
import '../../../blocs/reminder/reminder_state.dart';
import '../../../blocs/water/water_bloc.dart';
import '../../../blocs/water/water_event.dart';
import '../../../service/notification_service.dart';

class ReminderSettingsScreen extends StatelessWidget {
  final List<Duration> intervalOptions = [
    Duration(minutes: 1),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 3),
    Duration(hours: 4),
  ];

  ReminderSettingsScreen({super.key});
  // in hours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reminder Settings')),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          context.read<InWaterBloc>();
          context.read<ReminderBloc>();

          // Inject the real NotificationService into ReminderBloc
          // Use a setter or mutable injection pattern

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text("Enable Reminders"),
                  value: state.remindersEnabled,
                  onChanged: (value) {
                    context.read<ReminderBloc>().add(ToggleReminders(value));
                  },
                ),
                if (state.remindersEnabled) ...[
                  SizedBox(height: 24),
                  Text(
                    'Reminder Interval (hours)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  DropdownButton<Duration>(
                    value: state.interval,
                    onChanged: (newInterval) {
                      if (newInterval != null) {
                        context
                            .read<ReminderBloc>()
                            .add(SetReminderInterval(newInterval));
                        context
                            .read<ReminderBloc>()
                            .add(ScheduleNextReminderEvent());
                      }
                    },
                    items: intervalOptions.map((duration) {
                      final label = duration.inMinutes < 60
                          ? 'Every ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}'
                          : 'Every ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(label),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
