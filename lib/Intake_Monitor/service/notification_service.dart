import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServiceIn {
  final void Function(int amount) onIntakeLogged;
  final void Function()? onReschedule;

  NotificationServiceIn({
    required this.onIntakeLogged,
    this.onReschedule,
  });

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'hydration_channel',
          channelName: 'Hydration Reminders',
          channelDescription: 'Notifications to stay hydrated',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    // Ask for permission
    await AwesomeNotifications().isNotificationAllowed().then((allowed) {
      if (!allowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Handle action tap
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (action) async {
        final buttonKey = action.buttonKeyPressed;
        if (buttonKey == 'log_250ml') {
          onIntakeLogged(250);
          onReschedule?.call();
        } else if (buttonKey == 'log_500ml') {
          onIntakeLogged(500);
          onReschedule?.call();
        }
      },
    );
  }

  Future<void> showInstantReminder(int currentIntake, int goal) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'hydration_channel',
        title: 'Time to Hydrate!',
        body: "You've consumed $currentIntake ml out of your $goal ml goal",
        notificationLayout: NotificationLayout.Default,
        payload: {
          'currentIntake': '$currentIntake',
          'goal': '$goal',
        },
      ),
      actionButtons: [
        NotificationActionButton(key: 'log_250ml', label: 'Drink 250ml'),
        NotificationActionButton(key: 'log_500ml', label: 'Drink 500ml'),
      ],
    );
  }

  Future<void> scheduleRepeatingNotifications(
      Duration interval, int currentIntake, int goal) async {
    final now = tz.TZDateTime.now(tz.local);
    final triggerTime = now.add(interval);

    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        year: triggerTime.year,
        month: triggerTime.month,
        day: triggerTime.day,
        hour: triggerTime.hour,
        minute: triggerTime.minute,
        second: 0,
        millisecond: 0,
        timeZone: tz.local.name,
        repeats: true, // enable repeating
      ),
      content: NotificationContent(
        id: 1,
        channelKey: 'hydration_channel',
        title: 'Stay Hydrated 💧',
        body: 'Tap to log your water!',
        notificationLayout: NotificationLayout.Default,
        payload: {
          'currentIntake': '$currentIntake',
          'goal': '$goal',
        },
      ),
      actionButtons: [
        NotificationActionButton(key: 'log_250ml', label: 'Drink 250ml'),
        NotificationActionButton(key: 'log_500ml', label: 'Drink 500ml'),
      ],
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
