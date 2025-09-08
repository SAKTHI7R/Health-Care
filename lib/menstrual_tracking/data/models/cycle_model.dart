import 'package:cloud_firestore/cloud_firestore.dart';

class CycleModel {
  final DateTime startDate;
  final DateTime endDate;
  final int cycleLength;
  final int periodLength;

  CycleModel({
    required this.startDate,
    required this.endDate,
    required this.cycleLength,
    required this.periodLength,
  });

  Map<String, dynamic> toMap() => {
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'cycleLength': cycleLength,
        'periodLength': periodLength,
      };

  factory CycleModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value); // Legacy fix
      throw Exception("Invalid date format");
    }

    return CycleModel(
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      cycleLength: (map['cycleLength'] as int?) ?? 28,
      periodLength: (map['periodLength'] as int?) ?? 5,
    );
  }
}
