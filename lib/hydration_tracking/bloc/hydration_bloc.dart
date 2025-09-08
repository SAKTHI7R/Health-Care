import 'package:flutter_bloc/flutter_bloc.dart';

import '../notification.dart';
import '../repository/hydration_repository.dart';
import 'hydration_event.dart';
import 'hydration_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository repository;
  final NotificationService notificationService;

  WaterBloc(this.repository, this.notificationService) : super(WaterInitial()) {
    on<LoadWaterData>(_onLoad);
    on<AddWater>(_onAddWater);
    on<UpdateWaterSettings>(_onUpdateSettings);
    on<LogWaterFromNotification>(_onLogFromNotification);
    on<UpdateGoal>(_onUpdateGoal);
    on<ResetIntake>(_onResetIntake);
    notificationService.onWaterLogged = (int ml) {
      add(LogWaterFromNotification(ml));
    };
  }

  void _onLoad(LoadWaterData event, Emitter<WaterState> emit) async {
    emit(WaterLoading());
    try {
      final goal = await repository.fetchUserGoal();
      final doc = await repository.firestore
          .collection('users')
          .doc(repository.uid)
          .collection('waterIntake')
          .doc(repository.todayDate())
          .get();
      final intake = doc.data()?['intakeML'] ?? 0;
      notificationService.totalWaterIntake = intake;
      final settings = await repository.fetchWaterSettings();
      final remindersEnabled = settings['remindersEnabled'] ?? false;
      final interval = settings['intervalMinutes'] ?? 60;

      if (remindersEnabled && intake < goal) {
        await notificationService.scheduleRepeatingNotification(interval);
      } else {
        await notificationService.cancelAll(); // 🚨 Cancel if goal reached
      }

      emit(WaterLoaded(
        intake: intake,
        goal: goal,
        remindersEnabled: remindersEnabled,
        intervalMinutes: interval,
      ));
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  void _onAddWater(AddWater event, Emitter<WaterState> emit) async {
    try {
      await repository.addWaterIntake(event.ml);
      // Log the added amount
      add(LoadWaterData()); // Refresh the state
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  void _onLogFromNotification(
      LogWaterFromNotification event, Emitter<WaterState> emit) async {
    try {
      await repository.addWaterIntake(event.ml);
      add(LoadWaterData());
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<WaterState> emit) async {
    try {
      await repository.updateUserGoal(event.newGoal);
      add(LoadWaterData()); // reload state after updating goal
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  void _onUpdateSettings(
      UpdateWaterSettings event, Emitter<WaterState> emit) async {
    try {
      await repository.updateWaterSettings(
        autoSuggest: event.autoSuggest,
        customGoalML: event.customGoalML,
        intervalMinutes: event.intervalMinutes,
        remindersEnabled: event.remindersEnabled,
      );
      add(LoadWaterData());
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  void _onResetIntake(ResetIntake event, Emitter<WaterState> emit) async {
    try {
      await repository
          .resetTodayIntake(); // You need to implement this in your repository
      add(LoadWaterData());
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }
}
