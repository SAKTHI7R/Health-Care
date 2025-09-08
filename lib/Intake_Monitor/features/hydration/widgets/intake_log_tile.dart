// intake_log_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../blocs/water/water_state.dart';
// ← use WaterLog

class IntakeLogWidget extends StatelessWidget {
  final List<WaterLog> logs; // ← WaterLog, not IntakeLogItem

  const IntakeLogWidget({required this.logs, super.key});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Text("No water intake logged yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final time = DateFormat('hh:mm a').format(log.timestamp);
        return ListTile(
          leading: Icon(Icons.local_drink, color: Colors.blue),
          title: Text("${log.amountMl} ml"), // ← amountMl
          subtitle: Text(time),
        );
      },
    );
  }
}
