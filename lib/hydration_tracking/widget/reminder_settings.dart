import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/hydration_bloc.dart';
import '../bloc/hydration_event.dart';

class ReminderSettingsTile extends StatefulWidget {
  final bool remindersEnabled;
  final int intervalMinutes;

  const ReminderSettingsTile({
    super.key,
    required this.remindersEnabled,
    required this.intervalMinutes,
  });

  @override
  State<ReminderSettingsTile> createState() => _ReminderSettingsTileState();
}

class _ReminderSettingsTileState extends State<ReminderSettingsTile> {
  late bool enabled;
  late int selectedInterval;

  final intervalOptions = {
    1: 'Every 1 min',
  };

  @override
  void initState() {
    super.initState();
    enabled = widget.remindersEnabled;
    selectedInterval = widget.intervalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Hydration Reminders'),
              value: enabled,
              onChanged: (value) {
                setState(() => enabled = value);
                context.read<WaterBloc>().add(UpdateWaterSettings(
                      remindersEnabled: value,
                      intervalMinutes: selectedInterval,
                    ));
              },
            ),
            if (enabled)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: DropdownButtonFormField<int>(
                  value: selectedInterval,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: intervalOptions.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedInterval = val);
                      context.read<WaterBloc>().add(UpdateWaterSettings(
                            remindersEnabled: enabled,
                            intervalMinutes: val,
                          ));
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
