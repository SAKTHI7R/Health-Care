import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/intake_repository.dart';

import 'water_event.dart';
import 'water_state.dart';

class InWaterBloc extends Bloc<WaterEvent, WaterState> {
  final Waterrepository waterRepository;
  final String userId;

  InWaterBloc({
    required this.waterRepository,
    required this.userId,
  }) : super(WaterState(
          goalMl: 0,
          currentIntakeMl: 0,
          intakeLogs: [],
          intakeHistory: {},
        )) {
    on<SetWaterGoalEvent>(_onSetGoal);
    on<AddWaterIntakeEvent>(_onAddIntake);
    on<ResetDailyIntakeEvent>(_onResetDailyIntake);
    on<FetchDailyIntakeEvent>(_onFetchTodayLogs);
    on<FetchIntakeHistoryEvent>(_onFetchHistory);
    // on<ResetDailyGoal>(_onResetDaily);
  }

  void _onSetGoal(SetWaterGoalEvent event, Emitter<WaterState> emit) async {
    await waterRepository.setDailyGoal(userId, event.goalMl);
    emit(state.copyWith(goalMl: event.goalMl));
  }

  void _onAddIntake(AddWaterIntakeEvent event, Emitter<WaterState> emit) async {
    final log = WaterLog(event.amountMl, DateTime.now());
    await waterRepository.addWaterLog(userId, log);
    final updatedLogs = List<WaterLog>.from(state.intakeLogs)..add(log);
    final updatedIntake = state.currentIntakeMl + event.amountMl;
    emit(state.copyWith(
      intakeLogs: updatedLogs,
      currentIntakeMl: updatedIntake,
    ));
  }

  void _onResetDailyIntake(
      ResetDailyIntakeEvent event, Emitter<WaterState> emit) async {
    await waterRepository.resetTodayLogs(userId);
    emit(state.copyWith(currentIntakeMl: 0, intakeLogs: []));
  }

  void _onFetchTodayLogs(
      FetchDailyIntakeEvent event, Emitter<WaterState> emit) async {
    final goal = await waterRepository.getDailyGoal(userId);
    final logs = await waterRepository.fetchTodayLogs(userId);
    final total = logs.fold(0, (sum, log) => sum + log.amountMl);
    emit(state.copyWith(
      goalMl: goal,
      intakeLogs: logs,
      currentIntakeMl: total,
    ));
  }

  void _onFetchHistory(
      FetchIntakeHistoryEvent event, Emitter<WaterState> emit) async {
    final history = await waterRepository.fetchIntakeHistory(
      userId,
      event.startDate,
      event.endDate,
    );

    emit(state.copyWith(intakeHistory: history));
  }
/*
  void _onResetDaily(ResetDailyGoal event, Emitter<WaterState> emit) async {
    await waterRepository.resetDailyGoal(userId);

    // Optional: Also reset current intake and logs
    await waterRepository.resetTodayLogs(userId);

    final updatedGoal = await waterRepository.getDailyGoal(userId);
    final todayLogs = await waterRepository.fetchTodayLogs(userId);
    final total = todayLogs.fold(0, (sum, log) => sum + log.amountMl);

    emit(state.copyWith(
      goalMl: updatedGoal,
      currentIntakeMl: total,
      intakeLogs: todayLogs,
    ));
  }*/
}
