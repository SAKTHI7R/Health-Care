import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/intake_repository.dart';
import '../../service/notification_service.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final NotificationServiceIn notificationService;
  final String userId;
  final Waterrepository waterRepository;

  ReminderBloc({
    required this.notificationService,
    required this.userId,
    required this.waterRepository,
  }) : super(ReminderState(
            remindersEnabled: false, interval: Duration(hours: 2))) {
    on<ToggleReminders>((event, emit) async {
      emit(state.copyWith(remindersEnabled: event.enabled));
      final goal = await getUserGoal(userId); // Fetch goal dynamically
      if (event.enabled) {
        await notificationService.scheduleRepeatingNotifications(
            state.interval, 0, goal); // Pass dynamic goal
      } else {
        await notificationService.cancelAllNotifications();
      }
    });

    on<SetReminderInterval>((event, emit) async {
      emit(state.copyWith(interval: event.interval));
      final goal = await getUserGoal(userId); // Fetch goal dynamically
      if (state.remindersEnabled) {
        await notificationService.scheduleRepeatingNotifications(
            event.interval, 0, goal); // Pass dynamic goal
      }
    });
    on<ScheduleNextReminderEvent>((event, emit) async {
      final goal = await getUserGoal(userId);
      final todayIntake = await waterRepository.getCurrentIntake(userId);
      if (state.remindersEnabled) {
        await notificationService.scheduleRepeatingNotifications(
          state.interval,
          todayIntake,
          goal,
        );
      }
    });

    on<TriggerReminderNow>((event, emit) async {
      final currentIntake = 500; // Get dynamic value from state or repo
      final goal = await getUserGoal(userId); // Fetch goal dynamically
      await notificationService.showInstantReminder(
          currentIntake, goal); // Pass dynamic goal
    });
  }
  Future<int> getUserGoal(String userId) async {
    try {
      // Get the user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        // Fetch goal if it exists
        final goal =
            userDoc.data()?['goal'] ?? 2000; // Default goal is 2000 if not set
        return goal;
      } else {
        return 2000; // Default goal if user doesn't exist
      }
    } catch (e) {
      return 2000; // Default goal in case of an error
    }
  }
}
