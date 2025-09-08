import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadAppointments extends AppointmentEvent {
  final String uid;
  LoadAppointments({required this.uid});
}

class BookAppointment extends AppointmentEvent {
  final String uid;
  final String doctorName;
  final String doctorId;
  final DateTime date;

  BookAppointment({
    required this.uid,
    required this.doctorName,
    required this.doctorId,
    required this.date,
  });

  @override
  List<Object> get props => [uid, doctorName, doctorId, date];
}

class CancelAppointment extends AppointmentEvent {
  final String uid;
  final String appointmentId;

  CancelAppointment({required this.uid, required this.appointmentId});

  @override
  List<Object> get props => [uid, appointmentId];
}
