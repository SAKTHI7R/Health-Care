class HydrationReminder {
  final DateTime timestamp;
  final int amount;

  HydrationReminder({required this.timestamp, required this.amount});

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
      };

  factory HydrationReminder.fromJson(Map<String, dynamic> json) =>
      HydrationReminder(
        timestamp: DateTime.parse(json['timestamp']),
        amount: json['amount'],
      );
}
