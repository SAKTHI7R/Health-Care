import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentService appointmentService;

  AppointmentBloc({required this.appointmentService})
      : super(AppointmentInitial()) {
    on<LoadAppointments>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(event.uid)
            .collection('appointments')
            // Assuming you save uid
            .orderBy('date')
            .get();

        final appointments = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Appointment(
            id: doc.id,
            doctorId: data['doctorId'],
            doctorName: data['doctorName'],
            date: DateTime.parse(data['date']),
          );
        }).toList();

        emit(AppointmentLoaded(appointments));
      } catch (e) {
        emit(AppointmentFailed(e.toString()));
      }
    });

    on<CancelAppointment>((event, emit) async {
      emit(AppointmentLoading());
      try {
        await appointmentService.cancelAppointment(
          uid: event.uid,
          appointmentId: event.appointmentId,
        );
        emit(AppointmentCancelled());
        // Reload after cancellation
        final appointments =
            await appointmentService.getAppointments(uid: event.uid);
        emit(AppointmentLoaded(appointments));
      } catch (e) {
        emit(AppointmentFailed("Failed to cancel appointment: $e"));
      }
    });
  }
}
