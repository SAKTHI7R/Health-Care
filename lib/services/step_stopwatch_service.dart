import 'dart:async';
import 'package:pedometer/pedometer.dart';

class StepStopwatchService {
  final _stepController = StreamController<int>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  Stream<int> get stepStream => _stepController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  StreamSubscription<StepCount>? _subscription;
  Timer? _timer;

  int _startSteps = 0;
  int _currentSteps = 0;
  DateTime? _startTime;
  bool _isTracking = false;

  void startTracking() {
    if (_isTracking) return;

    _subscription = Pedometer.stepCountStream.listen((event) {
      if (!_isTracking) {
        _startSteps = event.steps;
        _startTime = DateTime.now();
        _startTimer();
        _isTracking = true;
      }
      _currentSteps = event.steps - _startSteps;
      _stepController.add(_currentSteps);
    }, onError: (error) {
      // print("Stopwatch step tracking error: $error");
    });
  }

  void stopTracking() {
    _subscription?.cancel();
    _stopTimer();
    _isTracking = false;
  }

  void resetTracking() {
    _startSteps += _currentSteps;
    _currentSteps = 0;
    _startTime = DateTime.now();
    _stepController.add(0);
    _durationController.add(Duration.zero);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        _durationController.add(elapsed);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _subscription?.cancel();
    _stopTimer();
    _stepController.close();
    _durationController.close();
  }

  bool get isTracking => _isTracking;
}
