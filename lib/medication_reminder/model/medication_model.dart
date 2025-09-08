import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final DateTime time;
  final bool isActive;
  final bool isMissed;
  final bool isTaken;
  final bool isAlertEnabled;

  Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.isActive,
    required this.isMissed,
    required this.isTaken,
    required this.isAlertEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'isMissed': isMissed,
      'isTaken': isTaken,
      'isAlertEnabled': isAlertEnabled,
    };
  }

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      name: data['name'] ?? '',
      time: DateTime.parse(data['time'] ?? ''),
      isActive: data['isActive'] ?? false,
      isMissed: data['isMissed'] ?? false,
      isTaken: data['isTaken'] ?? false,
      isAlertEnabled: data['isAlertEnabled'] ?? false,
    );
  }

  Medication copyWith({
    String? id,
    String? name,
    DateTime? time,
    bool? isAlertEnabled,
    bool? isTaken,
    bool? isActive,
    bool? isMissed,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
      isTaken: isTaken ?? this.isTaken,
      isActive: isActive ?? this.isActive,
      isMissed: isMissed ?? this.isMissed,
    );
  }
}
