import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleAppointmentReminder(
    String doctorName, DateTime appointmentTime) async {
  await notificationsPlugin.zonedSchedule(
    0,
    "Upcoming Appointment",
    "You have an appointment with $doctorName in 30 minutes.",
    tz.TZDateTime.from(
        appointmentTime.subtract(const Duration(minutes: 30)), tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails("channelId", "Appointment Reminder",
          importance: Importance.high),
    ),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
  );
}
