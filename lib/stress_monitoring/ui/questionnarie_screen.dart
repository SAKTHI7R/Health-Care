import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/stress_bloc.dart';
import '../bloc/stress_event.dart';
import '../bloc/stress_state.dart';
import '../data/models/stress_entry_model.dart';
import 'stress_summary_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Map<String, int> answers = {};

  final List<String> questions = [
    "You’re walking alone and hear footsteps behind you. What’s your first thought?",
    "When plans get canceled last minute, how do you feel?",
    "You receive a message saying ‘Can we talk?’ – what’s your reaction?",
    "You failed at something important. What do you tell yourself first?",
    "How often do you pretend to be okay when you're not?",
    "If someone doesn’t reply to your message, how do you feel?",
    "How easy is it for you to fall asleep at night?",
    "How often do you think about past mistakes?",
    "How often do you smile at people when you don’t want to?",
    "Do you sometimes feel tired even after a full night’s sleep?",
  ];

  final List<Map<String, dynamic>> options = [
    {"label": "😌 Very Relaxed", "value": 1},
    {"label": "🙂 Slightly Calm", "value": 2},
    {"label": "😐 Neutral", "value": 3},
    {"label": "😟 Slightly Anxious", "value": 4},
    {"label": "😰 Very Anxious", "value": 5},
  ];

  @override
  void initState() {
    super.initState();
    for (var question in questions) {
      answers[question] = 3; // Default to Neutral
    }
  }

  void _submitAnswers() {
    context.read<StressBloc>().add(SubmitAnswers(answers));

    // Listen once for StressLoaded, then show BottomSheet
    final subscription = context.read<StressBloc>().stream.listen((state) {
      if (state is StressLoaded) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          backgroundColor: Colors.white,
          builder: (context) => _StressResultSheet(entry: state.entry),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answers submitted successfully!')),
        );
      }
    });
    subscription.onDone(() {
      // Cancel the subscription when done
      subscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mind Comfort Analysis"),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics_outlined),
            tooltip: "View Stress Summary",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StressSummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((option) {
                      final isSelected = answers[question] == option["value"];
                      return ChoiceChip(
                        label: Text(option["label"]),
                        selected: isSelected,
                        selectedColor: Colors.blueAccent,
                        onSelected: (selected) {
                          setState(() {
                            answers[question] = option["value"];
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitAnswers,
        label: Text("Submit"),
        icon: Icon(Icons.check_circle_outline),
      ),
    );
  }
}

class _StressResultSheet extends StatelessWidget {
  final StressEntry entry;

  const _StressResultSheet({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = entry.stressScore;
    final emotion = entry.emotion;

    final isHighStress = score > 70;
    final isModerateStress = score > 40 && score <= 70;

    IconData moodIcon;
    Color color;
    String tip;

    if (isHighStress) {
      moodIcon = Icons.sentiment_very_dissatisfied;
      color = Colors.redAccent;
      tip = "Try deep breathing, meditation, or a short walk 🚶‍♂️";
    } else if (isModerateStress) {
      moodIcon = Icons.sentiment_neutral;
      color = Colors.orangeAccent;
      tip = "Relax with music, journaling, or stretching 🎵✍️";
    } else {
      moodIcon = Icons.sentiment_very_satisfied;
      color = Colors.green;
      tip = "Keep shining! Maintain your healthy habits 🌟";
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(moodIcon, color: color, size: 64),
          const SizedBox(height: 16),
          Text(
            "Your Mood: $emotion",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Stress Score: ${score.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Text(
            tip,
            style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text("Got it!", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
