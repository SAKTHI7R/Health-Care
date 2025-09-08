part of 'step_tracker_bloc.dart';

abstract class StepTrackerState extends Equatable {
  final int stepCount;
  final String pedestrianStatus;

  const StepTrackerState({this.stepCount = 0, this.pedestrianStatus = '?'});

  @override
  List<Object?> get props => [stepCount, pedestrianStatus];
}

class StepTrackerInitial extends StepTrackerState {}

class StepTrackerUpdated extends StepTrackerState {
  const StepTrackerUpdated(int stepCount, String pedestrianStatus)
      : super(stepCount: stepCount, pedestrianStatus: pedestrianStatus);
}

class StepTrackerError extends StepTrackerState {
  final String message;

  const StepTrackerError(this.message);

  @override
  List<Object?> get props => [message];
}
