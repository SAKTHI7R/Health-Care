import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save or update user profile
  Future<void> saveUserProfile(
      {required String name,
      required String phone,
      String? photoUrl,
      int? age,
      double? height,
      double? weight,
      String? bloodGroup,
      String? gender}) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': _auth.currentUser!.email,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      'age': age,
      'height': height,
      'weight': weight,
      'bloodGroup': bloodGroup,
      'gender': gender,
    }, SetOptions(merge: true)); // merge: update if doc exists
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    return doc.exists ? doc.data() : null;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(
      String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> deleteUserProfile(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }
}
