import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma("vm:entry-point")
Future<void> onActionReceivedBackground(ReceivedAction action) async {
  await Firebase.initializeApp(); // required for background
  final firestore = FirebaseFirestore.instance;

  int? intake;
  if (action.buttonKeyPressed == 'log_250ml') {
    intake = 250;
  } else if (action.buttonKeyPressed == 'log_500ml') {
    intake = 500;
  }

  if (intake != null) {
    final now = DateTime.now();
    final userId = FirebaseAuth.instance.currentUser
        ?.uid; // 🔁 Replace with actual user logic if needed

    await firestore
        .collection('hydration_logs')
        .doc(userId)
        .collection('intake')
        .add({
      'amount': intake,
      'timestamp': now,
    });

    // Optionally: schedule next reminder again
  }
}
