//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:health_care/core/theme/theme.dart';
import 'package:health_care/medication_reminder/bloc/medication_bloc.dart';
import 'package:health_care/profile/bloc/profile_bloc.dart';
import 'package:health_care/router/app_router.dart';

// ignore: unused_import
import 'package:health_care/services/hydration_service.dart';
import 'package:health_care/services/step_tracker_service.dart';
import 'package:health_care/weather/bloc/weather_bloc.dart';
import 'package:provider/provider.dart';
//import 'package:health_care/weather/widgets/weather_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:intl/intl.dart';
import 'dart:async';
//import 'package:health_care/blocs/step_tracker/step_tracker_bloc.dart'
// as tracker;
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';

// Import Screens
import 'Intake_Monitor/blocs/reminder/reminder_bloc.dart';
//import 'Intake_Monitor/blocs/reminder/reminder_event.dart';
import 'Intake_Monitor/blocs/water/water_bloc.dart';
import 'Intake_Monitor/blocs/water/water_event.dart';
import 'Intake_Monitor/data/repositories/intake_repository.dart';
import 'Intake_Monitor/notification_controller.dart';
import 'Intake_Monitor/service/notification_service.dart';
//import 'Stress_tracking/bloc/stress_bloc.dart';
import 'auth/bloc/auth_bloc.dart';
import 'auth/repository/auth_repository.dart';
import 'auth/ui/login_screen.dart';
import 'blocs/appointment/appointment_event.dart';

import 'core/theme/theme_cubit.dart';
/*
import 'hydration_tracking/bloc/hydration_bloc.dart';

import 'hydration_tracking/bloc/hydration_event.dart';
import 'hydration_tracking/notification.dart';
import 'hydration_tracking/repository/hydration_repository.dart';*/
import 'medication_reminder/bloc/medication_event.dart';
import 'medication_reminder/notification_service.dart';
import 'menstrual_tracking/bloc/menstrual_bloc.dart';
// Import BLoCs
import 'blocs/appointment/appointment_bloc.dart';
import 'blocs/heart_rate/heart_rate_bloc.dart';
import 'blocs/step_tracker/step_tracker_bloc.dart';
import 'blocs/step_stopwatch/step_stopwatch_bloc.dart';
import '../services/appointment_service.dart';
//import 'profile/profile_screen.dart';
import 'menstrual_tracking/bloc/menstrual_event.dart';

import 'profile/repository/profile_repository.dart';
//import 'screens/heart_rate_screen.dart';
import 'screens/ppg_view_screen.dart';
import 'services/step_stopwatch_service.dart';
import 'stress_monitoring/bloc/stress_bloc.dart';
import 'stress_monitoring/data/repositories/stress_repository.dart';
//import 'stress_monitoring/data/repositories/stress_repository.dart';

//import 'screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//late final WaterBloc waterBloc;
//late final NotificationService notifier;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //notifier = NotificationService();
  final prefs = await SharedPreferences.getInstance();
  final stepTrackerService = StepTrackerService();
  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();
  await Firebase.initializeApp();
  await initializeService();

  //final firestore = FirebaseFirestore.instance;

  //final auth = FirebaseAuth.instance;
  // final waterRepo = WaterRepository(firestore, auth);
  // waterBloc = WaterBloc(waterRepo, notifier);
  // notifier.onWaterLogged = (ml) {
  // waterBloc.add(LogWaterFromNotification(ml));
  // };

  // notifier.init();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'hydration_channel',
        channelName: 'Hydration Reminders',
        channelDescription: 'Reminders to drink water',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
    debug: true,
  );

  // Register background action listener
  AwesomeNotifications().setListeners(
    onActionReceivedMethod:
        onActionReceivedBackground, // 👈 This is your global function
  );
  await NotificationService.init();
  runApp(BlocProvider.value(
      value: themeCubit,
      child:
          HealthCareApp(prefs: prefs, stepTrackerService: stepTrackerService)));
}

class HealthCareApp extends StatelessWidget {
  final SharedPreferences prefs;
  final StepTrackerService stepTrackerService;
  // final WeatherRepository weatherRepository = WeatherRepository();

  const HealthCareApp(
      {super.key, required this.prefs, required this.stepTrackerService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        Provider<StressRepository>(
          create: (context) => StressRepository(FirebaseFirestore.instance),
        ),
        BlocProvider(
            create: (context) =>
                AppointmentBloc(appointmentService: AppointmentService())
                  ..add(LoadAppointments(
                      uid: FirebaseAuth.instance.currentUser?.uid as String))),
        /* BlocProvider<WaterBloc>(
          create: (ctx) => WaterBloc(
            ctx.read<
                WaterRepository>(), // Access WaterRepository from the context
            ctx.read<
                NotificationService>(), // Access NotificationService from the context
          )..add(LoadWaterData()), // Trigger LoadWaterData when screen loads
        ),*/
        BlocProvider(
          create: (context) {
            final firestore = FirebaseFirestore.instance;
            final uid = FirebaseAuth.instance.currentUser?.uid;
            final stepTrackerBloc =
                StepTrackerBloc(stepTrackerService, firestore, uid!);
            stepTrackerBloc.add(LoadStepTracker());
            return stepTrackerBloc;
          },
        ),
        BlocProvider(
          create: (context) => StepStopwatchBloc(StepStopwatchService()),
        ),
        BlocProvider(
          create: (_) => AuthBloc(AuthRepository()),
          child: LoginScreen(),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            profileRepository: ProfileRepository(),
          ),
        ),
        BlocProvider<MenstrualBloc>(
          create: (_) {
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) {
              throw Exception("User not authenticated");
            }
            return MenstrualBloc()..add(LoadCycleData(uid));
          },
        ),
        BlocProvider<StressBloc>(
          create: (context) => StressBloc(
            context.read<StressRepository>(), // ✅ This now works
            FirebaseAuth.instance.currentUser!.uid,
          ),
        ),
        BlocProvider(
          create: (_) => WeatherBloc(),
        ),
        BlocProvider(
          create: (_) => HeartRateBloc(),
          child: PPGCameraView(
            onReading: (bpm) {},
          ),
        ),
        // BlocProvider<StressBloc>(create: (_) => StressBloc()),
        BlocProvider(create: (_) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid == null) {
            throw Exception("User not authenticated");
          }
          return MedicationBloc(userId: uid)..add(LoadMedications());
        }),
        BlocProvider(create: (context) {
          final firestore = FirebaseFirestore.instance;
          final waterRepoIn = Waterrepository(firestore: firestore);
          final uid = FirebaseAuth.instance.currentUser?.uid;
          /*  final notificationService = NotificationServiceIn(
            onIntakeLogged: (amount) {
              // IMPORTANT: Access InWaterBloc context here
              context.read<InWaterBloc>().add(AddWaterIntakeEvent(amount));
            },
          ); notificationService.init();
          */

          return InWaterBloc(
            waterRepository: waterRepoIn,
            userId: uid as String,
          )..add(
              FetchDailyIntakeEvent(),
            );
        }),
        BlocProvider(
          create: (context) {
            final firestore = FirebaseFirestore.instance;
            final uid = FirebaseAuth.instance.currentUser?.uid;
            final waterRepoIn = Waterrepository(firestore: firestore);
            final notificationService =
                NotificationServiceIn(onIntakeLogged: (int amount) {
              context.read<InWaterBloc>().add(AddWaterIntakeEvent(amount));
            }); // No parameters
            notificationService.init();
            notificationService.showInstantReminder(0, 2000);

            return ReminderBloc(
              notificationService: notificationService,
              userId: uid ?? '',
              waterRepository: waterRepoIn,
            );
          },
        )
      ],
      child: BlocBuilder<ThemeCubit, ThemeState_c>(builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Healthcare App',
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: lightTheme,
          darkTheme: darkTheme,
          routerConfig: appRouter,
        );
      }),
    );
  }
}

// Background Service Initialization
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

bool onIosBackground(ServiceInstance service) {
  return true;
}

void onStart(ServiceInstance service) async {
  // final prefs = await SharedPreferences.getInstance();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Step Tracker Running",
      content: "Tracking steps in the background.",
    );
  }

  Pedometer.stepCountStream.listen((StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int lastSavedSteps = prefs.getInt('lastSavedSteps') ?? event.steps;
    int dailySteps = prefs.getInt('dailySteps') ?? 0;
    String? lastSavedDate = prefs.getString('lastSavedDate');

    if (lastSavedDate == null || lastSavedDate != today) {
      dailySteps = 0;
      lastSavedSteps = event.steps;
      prefs.setString('lastSavedDate', today);
    }

    int stepDifference = event.steps - lastSavedSteps;
    if (stepDifference > 0) dailySteps += stepDifference;

    prefs.setInt('lastSavedSteps', event.steps);
    prefs.setInt('dailySteps', dailySteps);
    prefs.setString('lastSavedDate', today);

    // ✅ Save to Firebase (inside onStart)
    final uid = prefs.getString('uid'); // Save UID on login to prefs
    if (uid != null) {
      final docId = today;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("steps")
          .doc(docId)
          .set({
        'steps': dailySteps,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 🔁 Update UI via BLoC (if app is open)
    final context = navigatorKey.currentContext;
    if (context != null) {
      BlocProvider.of<StepTrackerBloc>(context)
          .add(UpdateStepCount(dailySteps));
    }
  });
}
