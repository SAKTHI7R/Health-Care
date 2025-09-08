import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaterRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  WaterRepository(this.firestore, this.auth);

  String get uid => auth.currentUser!.uid;

  String todayDate() => DateTime.now().toIso8601String().substring(0, 10);

  Future<int> fetchUserGoal() async {
    final doc = await firestore.collection('users').doc(uid).get();
    final data = doc.data()?['waterSettings'] ?? {};

    if (data['autoSuggest'] == true) {
      final profileData = doc.data() ?? {};
      final weight = profileData['weight'] ?? 70.0;
      final height = profileData['height'] ?? 170.0;
      final age = profileData['age'] ?? 25;
      return _calculateSuggestedGoal(weight.toDouble(), height.toDouble(), age);
    } else {
      return data['customGoalML'] ?? 2000;
    }
  }

  int _calculateSuggestedGoal(double weight, double height, int age) {
    double base = weight * 30;
    if (age < 30) return base.toInt();
    if (age < 55) return (base - 100).toInt();
    return (base - 200).toInt();
  }

  Future<void> addWaterIntake(int ml) async {
    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('waterIntake')
        .doc(todayDate());

    await firestore.runTransaction((txn) async {
      final snapshot = await txn.get(doc);
      if (snapshot.exists) {
        txn.update(doc, {'intakeML': FieldValue.increment(ml)});
        txn.set(doc.collection('logs').doc(), {
          'ml': ml,
          'timestamp': DateTime.now(),
        });
      } else {
        final goal = await fetchUserGoal();
        txn.set(doc, {
          'date': todayDate(),
          'intakeML': ml,
          'goalML': goal,
        });
        txn.set(doc.collection('logs').doc(), {
          'ml': ml,
          'timestamp': DateTime.now(),
        });
      }
    });
  }

  Stream<DocumentSnapshot> getTodayIntakeStream() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('waterIntake')
        .doc(todayDate())
        .snapshots();
  }

  Stream<QuerySnapshot> getTodayLogsStream() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('waterIntake')
        .doc(todayDate())
        .collection('logs')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<Map<String, dynamic>> fetchWaterSettings() async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('hydration')
        .get();
    return doc.data() ?? {};
  }

  Future<void> updateWaterSettings({
    required bool remindersEnabled,
    required int intervalMinutes,
    int? customGoalML,
    bool? autoSuggest,
  }) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('waterIntake')
        .doc('settings')
        .set({
      'remindersEnabled': remindersEnabled,
      'intervalMinutes': intervalMinutes,
      if (customGoalML != null) 'customGoalML': customGoalML,
      if (autoSuggest != null) 'autoSuggest': autoSuggest,
    }, SetOptions(merge: true));
  }

  Future<void> updateUserGoal(int goal) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('waterIntake')
        .doc('settings')
        .set({'goal': goal}, SetOptions(merge: true));
  }

  Future<int?> getUserHydrationGoal() async {
    try {
      final docSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('waterIntake')
          .doc('settings')
          .get();

      final data = docSnapshot.data();
      return data?['customGoalML'] as int?;
    } catch (e) {
      //print('Error getting hydration goal: $e');
      return null;
    }
  }

  Future<void> resetTodayIntake() async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('waterIntake')
        .doc(todayDate())
        .set({'intakeML': 0});
  }
}
