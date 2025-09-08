import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medication_model.dart';

class MedicationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Medication>> fetchMedications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .get();

    return snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList();
  }

  Future<void> addMedication(String userId, Medication medication) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .doc();
    await docRef.set(medication.toMap());
  }

  Future<void> updateMedication(String userId, Medication medication) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .doc(medication.id);
    await docRef.update(medication.toMap());
  }

  Future<void> deleteMedication(String userId, String medicationId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .doc(medicationId);
    await docRef.delete();
  }
}
