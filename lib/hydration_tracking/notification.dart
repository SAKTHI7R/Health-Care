import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care/hydration_tracking/repository/hydration_repository.dart';
import 'package:timezone/data/latest.dart' as tz_data;
//import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  late void Function(int ml) onWaterLogged;

  int totalWaterIntake = 0; // Track total water intake (in ml)
  int goal = 0; // Default goal if custom goal is not set

  NotificationService();

  // Initialize the service and retrieve the hydration goal
  Future<void> init() async {
    // Fetch hydration goal from Firestore
    final hydrationGoal =
        await WaterRepository(FirebaseFirestore.instance, FirebaseAuth.instance)
            .fetchUserGoal();
    goal = hydrationGoal;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final actionId = response.actionId;
        handleNotificationAction(actionId); // Handle action click
      },
    );
  }

  // Handle the user's action on the notification
  void handleNotificationAction(String? actionId) {
    int ml = 0;
    switch (actionId) {
      case '100ml':
        ml = 100;
        break;
      case '250ml':
        ml = 250;
        break;
      case '500ml':
        ml = 500;
        break;
    }

    if (ml > 0) {
      totalWaterIntake += ml; // Add to total water intake
      onWaterLogged(ml); // Trigger the callback with the selected volume
    }
  }

  // Show hydration reminder notification
  Future<void> showImmediateHydrationReminder() async {
    await _plugin.show(
      1, // Notification ID
      '💧 Time to hydrate!',
      'How much water did you drink?',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Hydration Alerts',
          channelDescription: 'Reminds user to drink water',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          actions: [
            AndroidNotificationAction('100ml', '+100ml'),
            AndroidNotificationAction('250ml', '+250ml'),
            AndroidNotificationAction('500ml', '+500ml'),
          ],
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: '', // Optional payload, but actions will override
    );
  }

  // Schedules repeating notification at a custom interval
  Future<void> scheduleRepeatingNotification(int intervalMinutes) async {
    await cancelAll();

    Timer.periodic(Duration(minutes: intervalMinutes), (timer) async {
      if (totalWaterIntake < goal) {
        showImmediateHydrationReminder(); // Show reminder every interval
      } else {
        timer.cancel(); // Stop the timer once goal is reached
      }
    });
  }

  // Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
