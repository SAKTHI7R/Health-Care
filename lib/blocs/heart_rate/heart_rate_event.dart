part of 'heart_rate_bloc.dart';

abstract class HeartRateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartMonitoring extends HeartRateEvent {}

class NewCameraImage extends HeartRateEvent {
  final CameraImage image;
  NewCameraImage(this.image);
}

class CalculateBPM extends HeartRateEvent {}

class ToggleFlash extends HeartRateEvent {}

class ToggleCameraPreview extends HeartRateEvent {}
