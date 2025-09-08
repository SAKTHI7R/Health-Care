abstract class WaterEvent {}

class SetWaterGoalEvent extends WaterEvent {
  final int goalMl; // e.g., 2000
  SetWaterGoalEvent(this.goalMl);
}

class AddWaterIntakeEvent extends WaterEvent {
  final int amountMl; // e.g., 250
  AddWaterIntakeEvent(
    this.amountMl,
  );
}

class ResetDailyIntakeEvent extends WaterEvent {}

class FetchDailyIntakeEvent extends WaterEvent {}

class FetchIntakeHistoryEvent extends WaterEvent {
  final DateTime startDate;
  final DateTime endDate;
  FetchIntakeHistoryEvent(this.startDate, this.endDate);
}

class ResetDailyGoal extends WaterEvent {
  final String uid;
  ResetDailyGoal(this.uid);
}
