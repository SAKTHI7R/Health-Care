import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HydrationProgressWidget extends StatefulWidget {
  @override
  _HydrationProgressWidgetState createState() =>
      _HydrationProgressWidgetState();
}

class _HydrationProgressWidgetState extends State<HydrationProgressWidget> {
  int _waterIntake = 0;
  int _dailyGoal = 3000; // Default: 3 liters

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = prefs.getInt('waterIntake') ?? 0;
      _dailyGoal = prefs.getInt('dailyGoal') ?? 3000;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _waterIntake / _dailyGoal;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hydration Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 10,
            ),
            SizedBox(height: 5),
            Text("$_waterIntake / $_dailyGoal ml",
                style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
