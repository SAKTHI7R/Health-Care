import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Appointment>> getAppointments({required String uid}) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs.map((doc) => Appointment.fromDocument(doc)).toList();
  }

  Future<void> bookAppointment({
    required String uid,
    required String doctorId,
    required String doctorName,
    required DateTime date,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .add({
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAppointment({
    required String uid,
    required String appointmentId,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }
}
