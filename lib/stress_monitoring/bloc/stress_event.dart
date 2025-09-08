abstract class StressEvent {}

class SubmitAnswers extends StressEvent {
  final Map<String, int> answers;
  SubmitAnswers(this.answers);
}

class LoadLatestEntry extends StressEvent {
  final String uid;
  LoadLatestEntry(this.uid);
}
