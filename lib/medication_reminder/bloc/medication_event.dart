import '../model/medication_model.dart';

abstract class MedicationEvent {}

class LoadMedications extends MedicationEvent {}

class ToggleAlert extends MedicationEvent {
  final String id;
  final bool enable;
  ToggleAlert(this.id, this.enable);
}

class MarkTaken extends MedicationEvent {
  final String id;
  final bool taken;
  MarkTaken(this.id, this.taken);
}

class AddOrEditMedication extends MedicationEvent {
  final Medication medication;
  AddOrEditMedication(this.medication);
}

class DeleteMedication extends MedicationEvent {
  final String id;

  DeleteMedication(this.id);
}
