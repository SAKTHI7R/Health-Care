import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stress_entry_model.dart';

class StressRepository {
  final FirebaseFirestore _firestore;

  StressRepository(this._firestore);

  Future<void> saveStressEntry(String uid, StressEntry entry) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stress_entries')
        .add(entry.toMap());
  }

  Future<StressEntry?> getLatestEntry(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('stress_entries')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return StressEntry.fromMap(snapshot.docs.first.data());
  }
}
