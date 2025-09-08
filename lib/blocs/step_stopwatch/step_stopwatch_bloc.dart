import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'step_stopwatch_event.dart';
import 'step_stopwatch_state.dart';
import '../../services/step_stopwatch_service.dart';

class StepStopwatchBloc extends Bloc<StepStopwatchEvent, StepStopwatchState> {
  final StepStopwatchService _service;

  StreamSubscription<int>? _stepSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  int _stepCount = 0;
  Duration _duration = Duration.zero;

  StepStopwatchBloc(this._service) : super(StepStopwatchInitial()) {
    on<StartStepTracking>(_onStart);
    on<StopStepTracking>(_onStop);
    on<ResetStepTracking>(_onReset);
    on<StepStopwatchUpdated>(_onUpdated);
    on<StepStopwatchDurationUpdated>(_onDurationUpdated);
  }

  void _onStart(StartStepTracking event, Emitter<StepStopwatchState> emit) {
    _stepCount = 0;
    _duration = Duration.zero;
    _service.startTracking();

    _stepSubscription = _service.stepStream.listen((count) {
      add(StepStopwatchUpdated(count));
    });

    _durationSubscription = _service.durationStream.listen((duration) {
      add(StepStopwatchDurationUpdated(duration));
    });

    emit(StepStopwatchRunning(stepCount: _stepCount, duration: _duration));
  }

  void _onStop(StopStepTracking event, Emitter<StepStopwatchState> emit) {
    _service.stopTracking();
    _stepSubscription?.cancel();
    _durationSubscription?.cancel();
    emit(StepStopwatchPaused(stepCount: _stepCount, duration: _duration));
  }

  void _onReset(ResetStepTracking event, Emitter<StepStopwatchState> emit) {
    _service.resetTracking();
    _stepCount = 0;
    _duration = Duration.zero;
    emit(StepStopwatchInitial());
  }

  void _onUpdated(
      StepStopwatchUpdated event, Emitter<StepStopwatchState> emit) {
    _stepCount = event.stepCount;
    emit(StepStopwatchRunning(stepCount: _stepCount, duration: _duration));
  }

  void _onDurationUpdated(
      StepStopwatchDurationUpdated event, Emitter<StepStopwatchState> emit) {
    _duration = event.duration;
    emit(StepStopwatchRunning(stepCount: _stepCount, duration: _duration));
  }

  @override
  Future<void> close() {
    _stepSubscription?.cancel();
    _durationSubscription?.cancel();
    _service.dispose();
    return super.close();
  }
}
