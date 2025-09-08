class ReminderState {
  final bool remindersEnabled;
  final Duration interval;

  ReminderState({required this.remindersEnabled, required this.interval});

  ReminderState copyWith({bool? remindersEnabled, Duration? interval}) {
    return ReminderState(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      interval: interval ?? this.interval,
    );
  }
}
