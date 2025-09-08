class IntakeLogItem {
  final int amountMl;
  final DateTime timestamp;

  IntakeLogItem(this.amountMl, this.timestamp);
  int get amount => amountMl;
  Map<String, dynamic> toJson() => {
        'amountMl': amountMl,
        'timestamp': timestamp.toIso8601String(),
      };

  factory IntakeLogItem.fromJson(Map<String, dynamic> json) => IntakeLogItem(
        json['amountMl'],
        DateTime.parse(json['timestamp']),
      );
}
