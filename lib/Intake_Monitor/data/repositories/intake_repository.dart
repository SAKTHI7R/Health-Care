import 'package:cloud_firestore/cloud_firestore.dart';

import '../../blocs/water/water_state.dart';

class Waterrepository {
  final FirebaseFirestore firestore;

  Waterrepository({required this.firestore});

  // Firestore path: users -> uid -> water
  CollectionReference<Map<String, dynamic>> _userCollection(String uid) =>
      firestore.collection('users').doc(uid).collection('water');

  DocumentReference<Map<String, dynamic>> _goalDoc(String uid) =>
      firestore.collection('users').doc(uid).collection('meta').doc('goal');

  /// Set daily water goal (in ml)
  Future<void> setDailyGoal(String uid, int goalMl) async {
    await _goalDoc(uid).set({'goalMl': goalMl});
  }

  /// Get the current daily goal
  Future<int> getDailyGoal(String uid) async {
    final snapshot = await _goalDoc(uid).get();
    if (snapshot.exists &&
        snapshot.data() != null &&
        snapshot.data()!.containsKey('goalMl')) {
      return snapshot.data()!['goalMl'] as int;
    } else {
      return 0; // default fallback
    }
  }

  /// Add water log for the current user
  Future<void> addWaterLog(String uid, WaterLog log) async {
    final date = DateTime.now();
    final docId = '${date.year}-${date.month}-${date.day}';
    await _userCollection(uid).doc(docId).collection('logs').add(log.toJson());
  }

  /// Fetch today’s water logs
  Future<List<WaterLog>> fetchTodayLogs(String uid) async {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month}-${now.day}';

    final snapshot =
        await _userCollection(uid).doc(docId).collection('logs').get();
    return snapshot.docs.map((doc) => WaterLog.fromJson(doc.data())).toList();
  }

  /// Reset today’s intake by deleting logs
  Future<void> resetTodayLogs(String uid) async {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month}-${now.day}';
    final logsRef = _userCollection(uid).doc(docId).collection('logs');

    final snapshot = await logsRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Fetch water intake history between two dates
  Future<Map<String, int>> fetchIntakeHistory(
      String uid, DateTime start, DateTime end) async {
    final Map<String, int> history = {};

    for (DateTime date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      final docId = '${date.year}-${date.month}-${date.day}';
      final snapshot =
          await _userCollection(uid).doc(docId).collection('logs').get();
      final total = snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc.data()['amountMl'] as int? ?? 0),
      );
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      history[dateStr] = total;
    }

    return history;
  }

  /* Future<Map<DateTime, List<WaterLog>>> fetchIntakeHistoryTyped(
      String uid, DateTime start, DateTime end) async {
    final Map<DateTime, List<WaterLog>> history = {};

    for (DateTime date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      final docId = '${date.year}-${date.month}-${date.day}';
      final snapshot =
          await _userCollection(uid).doc(docId).collection('logs').get();

      final logs = snapshot.docs.map((doc) {
        final data = doc.data();
        return WaterLog(data['amountMl'] ?? 0, date);
      }).toList();

      if (logs.isNotEmpty) {
        history[date] = logs;
      }
    }

    return history;
  }*/

  /// Get today's current total intake in ml
  Future<int> getCurrentIntake(String uid) async {
    final logs = await fetchTodayLogs(uid);

    // Ensure logs is a List<WaterLog>
    final resolvedLogs = logs;

    if (resolvedLogs.isEmpty) return 0;

    return resolvedLogs.fold<int>(0, (sum, log) => sum + log.amountMl);
  }

/*  Future<void> resetDailyGoal(String uid) async {
    await _goalDoc(uid).set({'goalMl': 0});
  }*/
}
