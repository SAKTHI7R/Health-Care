import '../data/models/cycle_model.dart';

abstract class MenstrualState {}

class MenstrualInitial extends MenstrualState {}

class MenstrualLoading extends MenstrualState {}

class MenstrualLoaded extends MenstrualState {
  final CycleModel cycle;
  final DateTime nextStartDate;
  final DateTime nextEndDate;
  final Map<int, Map<String, String>> stages;

  MenstrualLoaded(
      this.cycle, this.nextStartDate, this.nextEndDate, this.stages);
}

class MenstrualError extends MenstrualState {
  final String message;
  MenstrualError(this.message);
}
