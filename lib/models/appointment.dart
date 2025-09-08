import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final DateTime date;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.date,
  });

  factory Appointment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      date: DateTime.parse(data['date']),
    );
  }
}
