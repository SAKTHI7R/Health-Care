import '../data/models/stress_entry_model.dart';

abstract class StressState {}

class StressInitial extends StressState {}

class StressLoading extends StressState {}

class StressLoaded extends StressState {
  final StressEntry entry;
  StressLoaded(this.entry);
}

class StressError extends StressState {
  final String message;
  StressError(this.message);
}
