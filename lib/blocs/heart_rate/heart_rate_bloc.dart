import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'heart_rate_event.dart';
part 'heart_rate_state.dart';

class HeartRateBloc extends Bloc<HeartRateEvent, HeartRateState> {
  late CameraController _controller;
  List<int> _redSamples = [];
  Timer? _bpmTimer;
  bool _processing = false;
  bool _flashOn = true;
  bool _showCamera = false;
  HeartRateBloc() : super(HeartRateInitial()) {
    on<StartMonitoring>(_onStartMonitoring);
    on<NewCameraImage>(_onNewCameraImage);
    on<CalculateBPM>(_onCalculateBPM);
    on<ToggleFlash>(_onToggleFlash);
    on<ToggleCameraPreview>(_onToggleCameraPreview);
  }

  Future<void> _onStartMonitoring(StartMonitoring event, Emitter emit) async {
    final cameras = await availableCameras();
    final backCamera = cameras.first;
    _controller =
        CameraController(backCamera, ResolutionPreset.low, enableAudio: false);
    await _controller.initialize();
    await _controller.setFlashMode(FlashMode.torch);
    _flashOn = true;
    await _controller.startImageStream((image) {
      add(NewCameraImage(image));
    });

    _bpmTimer = Timer.periodic(Duration(seconds: 3), (_) {
      add(CalculateBPM());
    });

    emit(HeartRateMeasuring(_controller, _flashOn,
        redSamples: List.from(_redSamples)));
  }

  void _onNewCameraImage(NewCameraImage event, Emitter emit) {
    _processCameraImage(event.image);
  }

  void _processCameraImage(CameraImage image) {
    if (_processing) return;
    _processing = true;

    try {
      final redAvg = _averageRedIntensity(image);
      _redSamples.add(redAvg);
      if (_redSamples.length > 150) {
        _redSamples = _redSamples.sublist(_redSamples.length - 150);
      }
    } finally {
      _processing = false;
    }
  }

  void _onCalculateBPM(CalculateBPM event, Emitter emit) {
    if (_redSamples.length < 2) return;

    final diffs = List.generate(
      _redSamples.length - 1,
      (i) => _redSamples[i + 1] - _redSamples[i],
    );

    final peaks = <int>[];
    for (int i = 1; i < diffs.length - 1; i++) {
      if (diffs[i - 1] > 0 && diffs[i] < 0 && _redSamples[i] > 128) {
        peaks.add(i);
      }
    }

    if (peaks.length < 2) return;
    final intervals =
        List.generate(peaks.length - 1, (i) => peaks[i + 1] - peaks[i]);
    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    final bpm = (60 * 30 / avgInterval).round();

    _saveToFirebase(bpm);

    emit(HeartRateUpdated(bpm, _flashOn));
  }

  void _onToggleFlash(ToggleFlash event, Emitter emit) async {
    if (!_controller.value.isInitialized) return;
    if (_flashOn) {
      await _controller.setFlashMode(FlashMode.off);
    } else {
      await _controller.setFlashMode(FlashMode.torch);
    }
    _flashOn = !_flashOn;
    emit(HeartRateFlashToggled(_flashOn));
  }

  int _averageRedIntensity(CameraImage image) {
    final bytes = image.planes[0].bytes;
    int sum = 0;
    for (int i = 0; i < bytes.length; i += 4) {
      sum += bytes[i];
    }
    return sum ~/ (bytes.length ~/ 4);
  }

  void _saveToFirebase(int bpm) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final timestamp = DateTime.now().toIso8601String();

      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('heart_rate')
          .add({
        'bpm': bpm,
        'timestamp': timestamp,
      });
    }
  }

  void _onToggleCameraPreview(ToggleCameraPreview event, Emitter emit) {
    _showCamera = !_showCamera;
    emit(HeartRateCameraPreviewToggled(_showCamera));
  }

  @override
  Future<void> close() {
    _controller.dispose();
    _bpmTimer?.cancel();
    return super.close();
  }
}
