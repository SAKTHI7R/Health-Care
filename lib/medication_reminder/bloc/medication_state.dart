import '../model/medication_model.dart';

abstract class MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<Medication> medications;
  MedicationLoaded(this.medications);
}
