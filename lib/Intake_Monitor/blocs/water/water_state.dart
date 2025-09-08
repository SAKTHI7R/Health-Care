class WaterState {
  final int goalMl;
  final int currentIntakeMl;
  final List<WaterLog> intakeLogs;
  final Map<String, int> intakeHistory; // "yyyy-MM-dd" -> total

  WaterState({
    required this.goalMl,
    required this.currentIntakeMl,
    required this.intakeLogs,
    required this.intakeHistory,
  });

  WaterState copyWith({
    int? goalMl,
    int? currentIntakeMl,
    List<WaterLog>? intakeLogs,
    Map<String, int>? intakeHistory,
  }) {
    return WaterState(
      goalMl: goalMl ?? this.goalMl,
      currentIntakeMl: currentIntakeMl ?? this.currentIntakeMl,
      intakeLogs: intakeLogs ?? this.intakeLogs,
      intakeHistory: intakeHistory ?? this.intakeHistory,
    );
  }
}

class WaterLog {
  final int amountMl;
  final DateTime timestamp;

  WaterLog(this.amountMl, this.timestamp);

  Map<String, dynamic> toJson() => {
        'amountMl': amountMl,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        json['amountMl'],
        DateTime.parse(json['timestamp']),
      );
}
