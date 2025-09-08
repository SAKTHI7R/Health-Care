import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/hydration_service.dart';

class HydrationSettingsScreen extends StatefulWidget {
  @override
  _HydrationSettingsScreenState createState() =>
      _HydrationSettingsScreenState();
}

class _HydrationSettingsScreenState extends State<HydrationSettingsScreen> {
  int _selectedInterval = 60;
  final List<int> _intervals = [30, 45, 60, 90, 120]; // Options in minutes

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedInterval = prefs.getInt('reminderInterval') ?? 60;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderInterval', _selectedInterval);

    // Restart the reminder service with the new interval
    await HydrationService.restartReminder(_selectedInterval);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text("Reminder interval updated to $_selectedInterval minutes")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hydration Reminder Settings"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Reminder Interval:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "Reminder Interval",
                border: OutlineInputBorder(),
              ),
              value: _selectedInterval,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedInterval = newValue!;
                });
              },
              items: _intervals.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value minutes"),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
