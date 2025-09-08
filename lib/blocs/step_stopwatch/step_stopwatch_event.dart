// step_stopwatch_event.dart
abstract class StepStopwatchEvent {}

class StartStepTracking extends StepStopwatchEvent {}

class StopStepTracking extends StepStopwatchEvent {}

class ResetStepTracking extends StepStopwatchEvent {}

class StepStopwatchUpdated extends StepStopwatchEvent {
  final int stepCount;
  StepStopwatchUpdated(this.stepCount);
}

class StepStopwatchDurationUpdated extends StepStopwatchEvent {
  final Duration duration;
  StepStopwatchDurationUpdated(this.duration);
}
