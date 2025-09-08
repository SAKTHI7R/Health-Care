import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/step_tracker_service.dart';
import 'package:rxdart/rxdart.dart'; // Uncomment for debounce support

part 'step_tracker_event.dart';
part 'step_tracker_state.dart';

class StepTrackerBloc extends Bloc<StepTrackerEvent, StepTrackerState> {
  final StepTrackerService _stepTrackerService;
  final FirebaseFirestore _firestore;
  final String uid;

  StreamSubscription? _stepSubscription;
  StreamSubscription? _statusSubscription;
  int? _initialStepCount;

  StepTrackerBloc(this._stepTrackerService, this._firestore, this.uid)
      : super(StepTrackerInitial()) {
    on<LoadStepTracker>(_onLoadStepTracker);
    on<UpdateStepCount>(_onUpdateStepCount);
    on<UpdatePedestrianStatus>(_onUpdatePedestrianStatus);
    on<ResetStepBaseline>(_onResetBaseline);
  }

  Future<void> _onLoadStepTracker(
      LoadStepTracker event, Emitter<StepTrackerState> emit) async {
    try {
      await _stepTrackerService.initialize();

      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Restore baseline if saved
      _initialStepCount = prefs.getInt('initialStepCount_$today');

      _stepSubscription = _stepTrackerService.stepStream!
          .debounceTime(Duration(seconds: 2))
          .listen((event) async {
        if (_initialStepCount == null) {
          _initialStepCount = event.steps;
          await prefs.setInt('initialStepCount_$today', _initialStepCount!);
        }

        final correctedSteps = event.steps - _initialStepCount!;
        final safeSteps = correctedSteps < 0 ? 0 : correctedSteps;
        add(UpdateStepCount(safeSteps));
      });

      _statusSubscription = _stepTrackerService.statusStream!.listen((event) {
        add(UpdatePedestrianStatus(event.status));
      });
    } catch (e) {
      emit(StepTrackerError("Error initializing step tracker: $e"));
    }
  }

  /*Future<void> _onLoadStepTracker(
      LoadStepTracker event, Emitter<StepTrackerState> emit) async {
    try {
      await _stepTrackerService.initialize();

      if (_stepTrackerService.stepStream != null) {
        _stepSubscription = _stepTrackerService.stepStream!
            .debounceTime(Duration(seconds: 0)) // Add debounce time
            .listen((event) {
          _initialStepCount ??= event.steps;
          final correctedSteps = event.steps - _initialStepCount!;
          final safeSteps = correctedSteps < 0 ? 0 : correctedSteps;
          add(UpdateStepCount(safeSteps)); // Update step count with safe value
        });
      }

      if (_stepTrackerService.statusStream != null) {
        _statusSubscription = _stepTrackerService.statusStream!.listen((event) {
          add(UpdatePedestrianStatus(event.status));
        });
      }
    } catch (e) {
      emit(StepTrackerError("Error initializing step tracker: $e"));
    }
  }*/

  void _onUpdateStepCount(
      UpdateStepCount event, Emitter<StepTrackerState> emit) {
    emit(StepTrackerUpdated(event.stepCount, state.pedestrianStatus));

    _saveStepsToFirestore(event.stepCount); // 🔥 Save to Firebase
  }

  void _onUpdatePedestrianStatus(
      UpdatePedestrianStatus event, Emitter<StepTrackerState> emit) {
    emit(StepTrackerUpdated(state.stepCount, event.status));
  }

  void _onResetBaseline(
      ResetStepBaseline event, Emitter<StepTrackerState> emit) {
    _initialStepCount = null;
  }

  Future<void> _saveStepsToFirestore(int steps) async {
    try {
      final now = DateTime.now();
      final docId = DateFormat('yyyy-MM-dd').format(now);
      final path = _firestore
          .collection('users')
          .doc(uid)
          .collection('steps')
          .doc(docId);

      await path.set({
        'steps': steps,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      //print('❌ Error saving steps to Firestore: $e');
    }
  }

  @override
  Future<void> close() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }
}
