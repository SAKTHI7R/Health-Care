import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/stress_entry_model.dart';
import '../data/repositories/stress_repository.dart';
import 'stress_event.dart';
import 'stress_state.dart';

class StressBloc extends Bloc<StressEvent, StressState> {
  final StressRepository repository;
  final String uid;

  StressBloc(this.repository, this.uid) : super(StressInitial()) {
    on<SubmitAnswers>(_onSubmitAnswers);
    on<LoadLatestEntry>(_onLoadLatestEntry);
  }

  Future<void> _onSubmitAnswers(
      SubmitAnswers event, Emitter<StressState> emit) async {
    emit(StressLoading());

    final score =
        event.answers.values.reduce((a, b) => a + b) / event.answers.length;

    final emotion = _mapScoreToEmotion(score);
    final entry = StressEntry(
      timestamp: DateTime.now(),
      answers: event.answers,
      stressScore: score,
      emotion: emotion,
    );

    await repository.saveStressEntry(uid, entry);
    emit(StressLoaded(entry));
  }

  Future<void> _onLoadLatestEntry(
      LoadLatestEntry event, Emitter<StressState> emit) async {
    emit(StressLoading());
    final entry = await repository.getLatestEntry(event.uid);
    if (entry != null) {
      emit(StressLoaded(entry));
    } else {
      emit(StressError('No entry found.'));
    }
  }

  String _mapScoreToEmotion(double score) {
    if (score < 2) return "Happy";
    if (score < 3.5) return "Neutral";
    if (score < 4.5) return "Stressed";
    return "Very Stressed";
  }
}
