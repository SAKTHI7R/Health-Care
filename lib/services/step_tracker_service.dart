import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepTrackerService {
  Stream<StepCount>? _stepStream;
  Stream<PedestrianStatus>? _statusStream;

  Stream<StepCount>? get stepStream => _stepStream;
  Stream<PedestrianStatus>? get statusStream => _statusStream;

  // Request Activity Recognition Permission
  Future<bool> requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.activityRecognition.request();
    }
    return status.isGranted;
  }

  // Initialize Pedometer Streams
  Future<void> initialize() async {
    bool granted = await requestPermission();
    if (!granted) {
      throw Exception("Permission Denied");
    }

    _stepStream = Pedometer.stepCountStream;
    _statusStream = Pedometer.pedestrianStatusStream;
  }
}
