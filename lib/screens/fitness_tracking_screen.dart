import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/widgets/skeleton.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../blocs/step_stopwatch/step_stopwatch_event.dart';
import '../blocs/step_stopwatch/step_stopwatch_state.dart';
import '../blocs/step_tracker/step_tracker_bloc.dart';
import '../blocs/step_stopwatch/step_stopwatch_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/fit_weather.dart';

class FitnessTrackingScreen extends StatefulWidget {
  const FitnessTrackingScreen({super.key});

  @override
  State<FitnessTrackingScreen> createState() => _FitnessTrackingScreenState();
}

class _FitnessTrackingScreenState extends State<FitnessTrackingScreen> {
  String _weatherCondition = "Fetching...";
  String _suggestion = "Loading suggestions...";

  final TextEditingController _cityController = TextEditingController();
  // ignore: unused_field
  bool _isFetchingLocation = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocationWeather();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  double _calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25.0) return "Normal";
    if (bmi < 30.0) return "Overweight";
    return "Obese";
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case "Underweight":
        return Colors.blue;
      case "Normal":
        return Colors.green;
      case "Overweight":
        return Colors.orange;
      case "Obese":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _getLocationWeather() async {
    setState(() => _isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint("Location permission denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint("Position: ${position.latitude}, ${position.longitude}");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        String? city = placemarks.first.locality;
        if (city != null && city.isNotEmpty) {
          _cityController.text = city;
          debugPrint("Detected city: $city");
          _fetchWeatherAndSuggestions(city);
        } else {
          debugPrint("City not found in placemarks.");
        }
      } else {
        debugPrint("No placemarks found.");
      }
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _fetchWeatherAndSuggestions(String city) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse("https://wttr.in/$city?format=j1"));
      final data = jsonDecode(response.body);
      final condition = data["current_condition"][0]["weatherDesc"][0]["value"];
      final tempC =
          double.tryParse(data["current_condition"][0]["temp_C"]) ?? 0;

      setState(() {
        _weatherCondition = "$condition, ${tempC.toStringAsFixed(1)}°C";
        _suggestion = _generateSuggestion(condition.toLowerCase(), tempC);
      });
    } catch (e) {
      setState(() {
        _weatherCondition = "Unavailable";
        _suggestion = "Unable to load weather-based suggestion.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateSuggestion(String condition, double tempC) {
    if (condition.contains("rain") || condition.contains("storm")) {
      return "It's best to stay indoors. Try a home workout or a quick fitness game.";
    } else if (condition.contains("clear") || condition.contains("sunny")) {
      return "Great weather for a walk or outdoor jog!";
    } else if (tempC >= 32) {
      return "Stay hydrated! It's hot outside — drink extra water.";
    } else if (tempC <= 10) {
      return "It's cold — consider indoor cardio or strength training.";
    } else {
      return "Mild weather — your choice of indoor or outdoor activity!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data;
        final double? height =
            double.tryParse(profile?['height']?.toString() ?? '');
        final double? weight =
            double.tryParse(profile?['weight']?.toString() ?? '');
        double bmi = 0;
        String bmiCategory = '';
        final bool validProfile = height != null && weight != null;
        if (validProfile) {
          bmi = _calculateBMI(weight, height);
          bmiCategory = _getBMICategory(bmi);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Fitness Tracking"),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BlocBuilder<StepTrackerBloc, StepTrackerState>(
                  builder: (context, state) {
                    int dailySteps =
                        (state is StepTrackerUpdated) ? state.stepCount : 0;
                    return _buildMetricCard(
                      icon: Icons.directions_walk,
                      label: "Daily Steps",
                      value: dailySteps.toString(),
                      color: Colors.deepPurple,
                    );
                  },
                ),
                if (validProfile)
                  _buildMetricCard(
                    icon: Icons.monitor_weight,
                    label: "BMI ($bmiCategory)",
                    value: bmi.toStringAsFixed(1),
                    color: _getBMIColor(bmiCategory),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("BMI data unavailable."),
                  ),
                BlocBuilder<StepStopwatchBloc, StepStopwatchState>(
                  builder: (context, state) {
                    int sessionSteps = state.stepCount;
                    Duration duration = state.duration;
                    bool isTracking = state is StepStopwatchRunning;
                    bool isPaused = state is StepStopwatchPaused;
                    double caloriesBurned = sessionSteps * 0.04;

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.teal.withOpacity(0.1),
                                  child: const Icon(Icons.fitness_center,
                                      color: Colors.teal, size: 28),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(
                                  child: Text(
                                    "Session Steps",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  sessionSteps.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10.0,
                              runSpacing: 10.0,
                              children: [
                                _buildMetricCard(
                                  icon: Icons.timer,
                                  label: "Session Duration",
                                  value: _formatDuration(duration),
                                  color: Colors.indigo,
                                ),
                                _buildMetricCard(
                                  icon: Icons.local_fire_department,
                                  label: "Calories Burned",
                                  value:
                                      "${caloriesBurned.toStringAsFixed(1)} kcal",
                                  color: Colors.orange,
                                ),
                                _buildMetricCard(
                                  icon: Icons.track_changes,
                                  label: "Status",
                                  value: isTracking
                                      ? "Tracking"
                                      : isPaused
                                          ? "Paused"
                                          : "Idle",
                                  color: isTracking
                                      ? Colors.green
                                      : isPaused
                                          ? Colors.orange
                                          : Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildActionButton(
                                  label: isTracking ? "Pause" : "Start",
                                  icon: isTracking
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: isTracking
                                      ? Colors.red
                                      : Colors.green[600]!,
                                  onPressed: () {
                                    context.read<StepStopwatchBloc>().add(
                                          isTracking
                                              ? StopStepTracking()
                                              : StartStepTracking(),
                                        );
                                  },
                                ),
                                const SizedBox(width: 20),
                                _buildActionButton(
                                  label: "Reset",
                                  icon: Icons.refresh,
                                  color: Colors.grey,
                                  onPressed: () => context
                                      .read<StepStopwatchBloc>()
                                      .add(ResetStepTracking()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? WeatherCardSkeleton()
                    : WeatherCard(
                        weatherCondition: _weatherCondition,
                      ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _suggestion,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
