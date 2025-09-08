import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HydrationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FlutterTts _tts = FlutterTts();
  static Timer? _reminderTimer;

  static Future<void> initializeService() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(settings);
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    final prefs = await SharedPreferences.getInstance();
    bool remindersEnabled = prefs.getBool('remindersEnabled') ?? true;

    if (remindersEnabled) {
      _startHydrationReminder();
    }
  }

  static bool _isSpeaking = false;

  static Future<void> _showHydrationReminder() async {
    if (_isSpeaking) return;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'hydration_channel',
      'Hydration Reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Drink Water Reminder',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      "Time to Hydrate! 💧",
      "Drink some water to stay healthy!",
      platformDetails,
    );
    _isSpeaking = true;

    _tts.speak("It's time to drink water! Stay hydrated!");
    _tts.setCompletionHandler(() {
      _isSpeaking = false; // Reset when speaking is done
    });
  }

  static Future<void> _startHydrationReminder() async {
    _reminderTimer?.cancel(); // Ensure only one timer exists
    final prefs = await SharedPreferences.getInstance();
    int interval = prefs.getInt('reminderInterval') ?? 60;

    _reminderTimer = Timer.periodic(Duration(minutes: interval), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      int waterIntake = prefs.getInt('waterIntake') ?? 0;
      int dailyGoal = prefs.getInt('dailyGoal') ?? 3000;

      if (waterIntake >= dailyGoal) {
        timer.cancel();
      } else {
        _showHydrationReminder();
      }
    });
  }

  static Future<void> restartReminder(int interval) async {
    _reminderTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('reminderInterval', interval); // Save new interval
    _startHydrationReminder();
  }

  static Future<void> logWaterIntake(int waterIntake) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('waterIntake', waterIntake);
  }
}
