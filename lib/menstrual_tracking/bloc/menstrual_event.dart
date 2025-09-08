import '../data/models/cycle_model.dart';

abstract class MenstrualEvent {}

class LoadCycleData extends MenstrualEvent {
  final String uid;
  LoadCycleData(this.uid);
}

class SaveCycleData extends MenstrualEvent {
  final String uid;
  final CycleModel cycle;
  SaveCycleData(this.uid, this.cycle);
}

class ResetCycleData extends MenstrualEvent {
  final String uid;
  ResetCycleData(this.uid);
}

class ShowPredictionConfirmationDialog extends MenstrualEvent {
  final DateTime predictedStartDate;
  final DateTime lastEnteredDate;

  ShowPredictionConfirmationDialog(
      this.predictedStartDate, this.lastEnteredDate);
}
