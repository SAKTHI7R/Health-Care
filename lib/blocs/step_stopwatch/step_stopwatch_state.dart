// step_stopwatch_state.dart
abstract class StepStopwatchState {
  final int stepCount;
  final Duration duration;

  StepStopwatchState({required this.stepCount, required this.duration});
}

class StepStopwatchInitial extends StepStopwatchState {
  StepStopwatchInitial() : super(stepCount: 0, duration: Duration.zero);
}

class StepStopwatchRunning extends StepStopwatchState {
  StepStopwatchRunning({required super.stepCount, required super.duration});
}

class StepStopwatchPaused extends StepStopwatchState {
  StepStopwatchPaused({required super.stepCount, required super.duration});
}
