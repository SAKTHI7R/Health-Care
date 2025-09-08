import 'package:equatable/equatable.dart';

abstract class WaterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWaterData extends WaterEvent {}

class AddWater extends WaterEvent {
  final int ml;
  AddWater(this.ml);

  @override
  List<Object?> get props => [ml];
}

class ResetIntake extends WaterEvent {}

class LogWaterFromNotification extends WaterEvent {
  final int ml;
  LogWaterFromNotification(this.ml);

  @override
  List<Object?> get props => [ml];
}

class UpdateGoal extends WaterEvent {
  final int newGoal;
  UpdateGoal(this.newGoal);
}

class UpdateWaterSettings extends WaterEvent {
  final bool remindersEnabled;
  final int intervalMinutes;
  final int? customGoalML;
  final bool? autoSuggest;

  UpdateWaterSettings({
    required this.remindersEnabled,
    required this.intervalMinutes,
    this.customGoalML,
    this.autoSuggest,
  });

  @override
  List<Object?> get props =>
      [autoSuggest, customGoalML, intervalMinutes, remindersEnabled];
}
