part of 'heart_rate_bloc.dart';

abstract class HeartRateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HeartRateInitial extends HeartRateState {}

class HeartRateMeasuring extends HeartRateState {
  final CameraController controller;
  final bool flashOn;
  final List<int> redSamples;

  HeartRateMeasuring(this.controller, this.flashOn,
      {this.redSamples = const []});

  @override
  List<Object> get props => [controller, flashOn, redSamples];
}

class HeartRateUpdated extends HeartRateState {
  final int bpm;
  final bool flashOn;
  HeartRateUpdated(this.bpm, this.flashOn);
}

class HeartRateFlashToggled extends HeartRateState {
  final bool flashOn;
  HeartRateFlashToggled(this.flashOn);
}

class HeartRateCameraPreviewToggled extends HeartRateState {
  final bool showCamera;
  HeartRateCameraPreviewToggled(this.showCamera);
}
