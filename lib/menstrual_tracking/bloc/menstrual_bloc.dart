import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/cycle_model.dart';
import 'menstrual_event.dart';
import 'menstrual_state.dart';

class MenstrualBloc extends Bloc<MenstrualEvent, MenstrualState> {
  MenstrualBloc() : super(MenstrualInitial()) {
    on<LoadCycleData>(_onLoad);
    on<SaveCycleData>(_onSave);
    on<ResetCycleData>(_onReset);
    on<ShowPredictionConfirmationDialog>(_onShowPredictionDialog);
  }

  Future<void> _onLoad(LoadCycleData event, Emitter emit) async {
    emit(MenstrualLoading());
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(event.uid)
          .collection('menstrual')
          .doc('cycle');

      final doc = await docRef.get();

      if (!doc.exists || doc.data() == null) {
        emit(MenstrualError("No cycle data found."));
        return;
      }

      CycleModel data = CycleModel.fromMap(doc.data()!);
      final today = DateTime.now();

      final nextStart = data.startDate.add(Duration(days: data.cycleLength));
      final nextEnd = nextStart.add(Duration(days: data.periodLength - 1));

      // Prediction confirmation logic
      if (today.isAfter(nextStart.subtract(Duration(days: 1))) &&
          today.isBefore(nextStart.add(Duration(days: 1)))) {
        final predictedStartDate = nextStart;
        final lastEnteredDate = data.startDate;

        if (predictedStartDate.isAfter(lastEnteredDate) &&
            today.isBefore(lastEnteredDate.add(Duration(days: 35)))) {
          // Show the confirmation dialog only if the user has not confirmed within the last 35 days
          add(ShowPredictionConfirmationDialog(
              predictedStartDate, lastEnteredDate));
        }
      }

      // Auto-update logic if current date has passed nextEnd
      if (today.isAfter(nextEnd)) {
        final updatedCycle = CycleModel(
          startDate: nextStart,
          endDate: nextEnd,
          cycleLength: data.cycleLength,
          periodLength: data.periodLength,
        );
        await docRef.set(updatedCycle.toMap());
        data = updatedCycle;
      }

      final stageTips = _generateCycleStages(data);
      emit(MenstrualLoaded(data, nextStart, nextEnd, stageTips));
    } catch (e) {
      emit(MenstrualError("Error loading data: ${e.toString()}"));
    }
  }

  Future<void> _onShowPredictionDialog(
      ShowPredictionConfirmationDialog event, Emitter emit) async {
    // Trigger the state to show the dialog in the UI
    emit(ShowPredictionConfirmationDialog(
      event.predictedStartDate,
      event.lastEnteredDate,
    ));
  }

  Future<void> _onSave(SaveCycleData event, Emitter emit) async {
    emit(MenstrualLoading());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.uid)
          .collection('menstrual')
          .doc('cycle')
          .set(event.cycle.toMap());

      add(LoadCycleData(event.uid));
    } catch (e) {
      emit(MenstrualError("Error saving data: ${e.toString()}"));
    }
  }

  Future<void> _onReset(ResetCycleData event, Emitter emit) async {
    emit(MenstrualLoading());
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(event.uid)
          .collection('menstrual')
          .doc('cycle');

      await docRef.delete(); // Delete from Firestore
      emit(MenstrualInitial()); // Go back to input state
    } catch (e) {
      emit(MenstrualError("Error resetting data: ${e.toString()}"));
    }
  }

  Map<int, Map<String, String>> _generateCycleStages(CycleModel cycle) {
    final totalDays = cycle.endDate.difference(cycle.startDate).inDays + 1;
    final Map<int, Map<String, String>> stages = {};

    for (int i = 1; i <= totalDays; i++) {
      if (i == 1) {
        stages[i] = {
          'stage': 'Menstrual',
          'tip': 'Stay hydrated and rest well',
        };
      } else if (i == 2) {
        stages[i] = {
          'stage': 'Follicular',
          'tip': 'Energy levels rising. Stay active!',
        };
      } else if (i == 3) {
        stages[i] = {
          'stage': 'Ovulation',
          'tip': 'Fertility is at its peak today.',
        };
      } else if (i == 4) {
        stages[i] = {
          'stage': 'Luteal',
          'tip': 'Mood swings possible. Eat healthy fats.',
        };
      }
    }

    return stages;
  }
}
