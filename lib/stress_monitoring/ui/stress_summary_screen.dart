import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/stress_bloc.dart';
import '../bloc/stress_state.dart';

class StressSummaryScreen extends StatelessWidget {
  const StressSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("How Are You Feeling?"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: BlocBuilder<StressBloc, StressState>(
        builder: (context, state) {
          if (state is StressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StressLoaded) {
            final emotion = state.entry.emotion;
            final score = state.entry.stressScore;
            final isHighStress = score > 70;
            final isModerateStress = score > 40 && score <= 70;

            IconData moodIcon;
            Color iconColor;
            String moodMessage;

            if (isHighStress) {
              moodIcon = Icons.sentiment_very_dissatisfied;
              iconColor = Colors.redAccent;
              moodMessage = "Take a deep breath. You've got this!";
            } else if (isModerateStress) {
              moodIcon = Icons.sentiment_neutral;
              iconColor = Colors.orangeAccent;
              moodMessage = "Hang in there, you're doing okay!";
            } else {
              moodIcon = Icons.sentiment_very_satisfied;
              iconColor = Colors.green;
              moodMessage = "You're doing great! Keep it up 🌟";
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  elevation: 10,
                  shadowColor: Colors.blue.shade100,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          child: Icon(
                            moodIcon,
                            color: iconColor,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emotion,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          moodMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Stress Score",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${score.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is StressError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(
            child: Text(
              "No data found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
