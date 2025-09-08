import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/medication_model.dart';
import 'medication_event.dart';
import 'medication_state.dart';
import '../notification_service.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;

  MedicationBloc({required this.userId}) : super(MedicationLoading()) {
    on<LoadMedications>((event, emit) async {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('medication')
          .get();

      final meds =
          snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList();

      emit(MedicationLoaded(meds));
    });

    on<ToggleAlert>((event, emit) async {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('medication')
          .doc(event.id);

      await docRef.update({'isAlertEnabled': event.enable});

      final doc = await docRef.get();
      final med = Medication.fromFirestore(doc);

      final notifId = med.time.millisecondsSinceEpoch ~/ 1000;

      if (event.enable) {
        await NotificationService.scheduleNotification(
          id: notifId,
          title: 'Time to take ${med.name}',
          body: 'Don\'t forget your medication.',
          scheduledTime: med.time,
        );
      } else {
        await NotificationService.cancelNotification(notifId);
      }

      add(LoadMedications());
    });

    on<MarkTaken>((event, emit) async {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('medication')
          .doc(event.id)
          .update({'isTaken': event.taken});
      add(LoadMedications());
    });

    on<AddOrEditMedication>((event, emit) async {
      final ref =
          firestore.collection('users').doc(userId).collection('medication');

      final med = event.medication;
      if (med.id.isEmpty) {
        await ref.add(med.toMap());
      } else {
        await ref.doc(med.id).set(med.toMap());
      }

      // Schedule or cancel based on isAlertEnabled
      final notifId = med.time.millisecondsSinceEpoch ~/ 1000;
      if (med.isAlertEnabled) {
        await NotificationService.scheduleNotification(
          id: notifId,
          title: 'Time to take ${med.name}',
          body: 'Don\'t forget your medication.',
          scheduledTime: med.time,
        );
      } else {
        await NotificationService.cancelNotification(notifId);
      }

      add(LoadMedications());
    });

    on<DeleteMedication>((event, emit) async {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('medication')
          .doc(event.id);

      final doc = await docRef.get();
      final med = Medication.fromFirestore(doc);
      await docRef.delete();

      await NotificationService.cancelNotification(
          med.time.millisecondsSinceEpoch ~/ 1000);

      add(LoadMedications());
    });
  }
}
