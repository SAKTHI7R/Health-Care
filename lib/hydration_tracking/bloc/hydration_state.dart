import 'package:equatable/equatable.dart';

abstract class WaterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WaterInitial extends WaterState {}

class WaterLoading extends WaterState {}

class WaterLoaded extends WaterState {
  final int intake;
  final int goal;
  final bool remindersEnabled;
  final int intervalMinutes;

  WaterLoaded({
    required this.intake,
    required this.goal,
    required this.remindersEnabled,
    required this.intervalMinutes,
  });
}

class WaterError extends WaterState {
  final String error;

  WaterError(this.error);

  @override
  List<Object?> get props => [error];
}
