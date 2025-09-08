part of 'step_tracker_bloc.dart';

abstract class StepTrackerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStepTracker extends StepTrackerEvent {}

class UpdateStepCount extends StepTrackerEvent {
  final int stepCount;

  UpdateStepCount(this.stepCount);

  @override
  List<Object?> get props => [stepCount];
}

class UpdatePedestrianStatus extends StepTrackerEvent {
  final String status;

  UpdatePedestrianStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class ResetStepBaseline extends StepTrackerEvent {}
