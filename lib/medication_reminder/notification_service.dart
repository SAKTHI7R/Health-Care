import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // icon resource (null uses app icon)
      [
        NotificationChannel(
          channelKey: 'med_channel',
          channelName: 'Medication Reminders',
          channelDescription: 'Reminder notifications for medications',
          defaultColor: Colors.black,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
        ),
      ],
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'med_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: scheduledTime.year,
        month: scheduledTime.month,
        day: scheduledTime.day,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true, // set to true if you want daily notifications
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<bool> requestPermission() async {
    return await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        return await AwesomeNotifications()
            .requestPermissionToSendNotifications();
      }
      return true;
    });
  }
}
