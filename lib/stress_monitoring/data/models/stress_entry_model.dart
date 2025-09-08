import 'package:cloud_firestore/cloud_firestore.dart';

class StressEntry {
  final DateTime timestamp;
  final Map<String, int> answers;
  final double stressScore;
  final String emotion;

  StressEntry({
    required this.timestamp,
    required this.answers,
    required this.stressScore,
    required this.emotion,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp,
        'answers': answers,
        'stressScore': stressScore,
        'emotion': emotion,
      };

  factory StressEntry.fromMap(Map<String, dynamic> map) {
    return StressEntry(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      answers: Map<String, int>.from(map['answers']),
      stressScore: map['stressScore'],
      emotion: map['emotion'],
    );
  }
}
