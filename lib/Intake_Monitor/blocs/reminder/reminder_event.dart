abstract class ReminderEvent {}

class ToggleReminders extends ReminderEvent {
  final bool enabled;
  ToggleReminders(this.enabled);
}

class SetReminderInterval extends ReminderEvent {
  final Duration interval;
  SetReminderInterval(this.interval);
}

class TriggerReminderNow extends ReminderEvent {}

class ScheduleNextReminderEvent extends ReminderEvent {}
