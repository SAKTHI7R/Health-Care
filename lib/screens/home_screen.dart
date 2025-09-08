//  External Packages
// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

//  Core Theme
import 'package:health_care/core/theme/theme_cubit.dart';

//  Features - Hydration Monitor
import 'package:health_care/Intake_Monitor/features/hydration/screens/dashboard_screen.dart';
import 'package:health_care/Intake_Monitor/features/hydration/widgets/TestHydrationScreen.dart';

// Features - Stress Tracking
//import '../Stress_tracking/Screen/camera_screen.dart';

//  Features - Heart Rate
import '../blocs/appointment/appointment_event.dart';
import '../emergency/emergency_helper.dart';
import '../emergency/hospital_map_screen.dart';
import '../screens/heart_rate_screen.dart';
import '../blocs/heart_rate/heart_rate_bloc.dart';

//  Features - Medication Reminder
import '../medication_reminder/ui/medication_screen.dart';
import '../medication_reminder/bloc/medication_bloc.dart';
import '../medication_reminder/bloc/medication_state.dart';
import '../medication_reminder/model/medication_model.dart';

// 🌸 Features - Menstrual Tracking
import '../menstrual_tracking/ui/menstrual_screen.dart';

// 👤 Features - Profile
import '../profile/profile_screen.dart';
import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_event.dart';
import '../profile/bloc/profile_state.dart';

//  Features - Appointments
import '../screens/appointment_screen.dart';
import '../blocs/appointment/appointment_bloc.dart';
import '../blocs/appointment/appointment_state.dart';

//  Features - Step Tracker & Fitness
import '../screens/step_tracker_screen.dart';
import '../screens/fitness_tracking_screen.dart';

//  Doctor Search
import '../screens/doctor_search_screen.dart';

//  Weather
import '../stress_monitoring/ui/questionnarie_screen.dart';
import '../weather/widgets/weather_banner.dart';

//  Widgets & Quick Actions

import '../widgets/health_summary_card.dart';

//  PPG (Photoplethysmography) View
import 'appointment_histroy_screen.dart';
import 'ppg_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> features = [
    {
      "title": "Profile",
      "icon": Icons.person,
      "screen": const ProfileScreen(),
    },
    {
      "title": "Medication Reminder",
      "icon": Icons.medication_liquid_outlined,
      "screen": MedicationScreen(userId: ''),
    },
    {
      "title": "Step Tracker",
      "icon": Icons.directions_walk,
      "screen": StepTrackerScreen(),
    },
    {
      "title": "Heart Rate Monitor",
      "icon": Icons.favorite,
      "screen": PPGCameraView(onReading: (int bpm) {}),
    },
    {
      "title": "Heart Rate (Realtime)",
      "icon": Icons.monitor_heart_rounded,
      "screen": PPGCameraView_sateless(onReading: (int bpm) {}),
    },
    {
      "title": "Stress Moinitoring",
      "icon": Icons.self_improvement_rounded,
      "screen": QuestionnaireScreen(),
    },
    {
      "title": "Hydration Reminder",
      "icon": Icons.local_drink_sharp,
      "screen": WaterDashboardScreen(userId: ''),
    },
    {
      "title": "Doctor Search",
      "icon": Icons.search,
      "screen": DoctorSearchScreen(),
    },
    {
      "title": "Appointments",
      "icon": Icons.event_available,
      "screen": AppointmentBookingScreen(),
    },
    {
      "title": "Fitness Tracking",
      "icon": Icons.fitness_center,
      "screen": const FitnessTrackingScreen(),
    },
    {
      "title": "Test Hydration",
      "icon": Icons.track_changes_outlined,
      "screen": TestHydrationScreen(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
    },
  ];

  Future<void> _loadFeaturesBasedOnGender() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final gender = userDoc.data()?['gender'];

    List<Map<String, dynamic>> tempFeatures =
        List.from(features); // make a copy

    if (gender != null && gender.toString().toLowerCase() == "female") {
      tempFeatures.insert(6, {
        "title": "Menstrual Tracking",
        "icon": Icons.calendar_today,
        "screen": const MenstrualScreen(),
      });
    }

    setState(() {
      features = tempFeatures;
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final screenWidth = MediaQuery.of(context).size.width;

    context
        .read<ProfileBloc>()
        .add(LoadUserProfile(FirebaseAuth.instance.currentUser?.uid ?? ''));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/chat'),
        icon: Icon(Icons.chat_bubble_outline),
        label: Text("Chat"),
        backgroundColor: theme.colorScheme.primary,
      ),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        title: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final greeting = getGreeting();
            if (state is ProfileLoaded) {
              final name = state.profile.name;
              final photoUrl = state.profile.photoUrl;
              final firstName = name.split(" ").first;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (name.isEmpty || state.profile.phone.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Complete Your Profile"),
                      content: Text(
                          "Please fill out your profile to access all features."),
                      actions: [
                        TextButton(
                          onPressed: () => context.go('/profile'),
                          child: Text("Edit Profile"),
                        ),
                      ],
                    ),
                  );
                }
              });

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("$greeting, $firstName",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.brightness_6),
                        onPressed: () =>
                            context.read<ThemeCubit>().toggleTheme(),
                      ),
                      IconButton(
                          icon: Icon(Icons.notifications), onPressed: () {}),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: ProfileScreen(),
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : AssetImage('assets/default_profile.jpg')
                                  as ImageProvider,
                        ),
                      )
                    ],
                  )
                ],
              );
            } else {
              return Text("$greeting, User 👋",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.normal));
            }
          },
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeatherBanner(city: ""),
                SizedBox(height: 20),
                BlocBuilder<HeartRateBloc, HeartRateState>(
                  builder: (context, state) {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final bpm = state is HeartRateUpdated
                        ? state.bpm.toString()
                        : "N/A";
                    return _buildHealthCards(bpm, uid!);
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle("Quick Actions", theme),
                SizedBox(height: 10),
                _buildQuickActions(),
                SizedBox(height: 20),
                _buildSectionTitle("Appointments", theme),
                SizedBox(height: 6),
                _buildAppointmentTimeline(),
                SizedBox(height: 10),
                BlocBuilder<MedicationBloc, MedicationState>(
                  builder: (context, state) {
                    if (state is MedicationLoaded &&
                        state.medications.isNotEmpty) {
                      // Get the next medication that is not taken and scheduled in future
                      final now = DateTime.now();
                      final upcomingMeds = state.medications
                          .where((med) => !med.isTaken && med.time.isAfter(now))
                          .toList()
                        ..sort((a, b) => a.time
                            .compareTo(b.time)); // sort to get the nearest one

                      final nextMed = upcomingMeds.isNotEmpty
                          ? upcomingMeds.first
                          : state.medications.first;

                      return _buildMedicationBar(nextMed);
                    } else {
                      return const SizedBox(); // No medications yet
                    }
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle("Explore Features", theme),
                SizedBox(height: 10),
                _buildFeatureGrid(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHealthCards(dynamic bpm, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("steps")
          .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _responsiveCard(
              "Steps", "0", Icons.directions_walk, Colors.orange);
        }
        final steps = snapshot.data!.get("steps") ?? 0;

        return Column(children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _responsiveCard(
                  "Steps", "$steps", Icons.directions_walk, Colors.orange),
              _responsiveCard("Rate", "$bpm bpm", Icons.favorite, Colors.red),
              _responsiveCard("Water", "2L", Icons.local_drink, Colors.blue),
              _responsiveCard("Sleep", "7h 30m", Icons.bedtime, Colors.purple),
            ],
          ),
        ]);
      },
    );
  }

  Widget _responsiveCard(
      String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 30,
      child: HealthSummaryCard(
          title: title, value: value, icon: icon, color: color),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _styledQuickActionButton(
            title: "Book Doctor",
            icon: Icons.medical_services,
            color: Colors.blueAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentBookingScreen(),
                ),
              );
            },
          ),
          _styledQuickActionButton(
            title: "Hospital Locator",
            icon: Icons.location_on,
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HospitalMapScreen()),
              );
            },
          ),
          _styledQuickActionButton(
            title: "Emergency",
            icon: Icons.warning,
            color: Colors.redAccent,
            onPressed: () async {
              await EmergencyHelper.emergencyCall();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("Calling nearest hospital (fallback: 108)...")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _styledQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTimeline() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AppointmentLoaded) {
          if (state.appointments.isEmpty) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.event_busy, color: Colors.redAccent),
                title: Text("No Upcoming Appointments"),
                subtitle: Text("You have no appointments scheduled."),
                trailing: Icon(Icons.add_circle_outline),
                onTap: () {
                  // Navigate to Book Appointment Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentHistoryScreen(),
                    ),
                  );
                },
              ),
            );
          }

          // ✅ Find upcoming appointment
          final now = DateTime.now();
          final upcomingAppointments = state.appointments
              .where((appointment) => appointment.date.isAfter(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          if (upcomingAppointments.isEmpty) {
            return Center(child: Text("No upcoming appointments."));
          }

          final nextAppointment = upcomingAppointments.first;

          // ✅ Return single card without ListView
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(Icons.event, color: Colors.blue),
              title: Text(nextAppointment.doctorName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd – kk:mm')
                        .format(nextAppointment.date),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTimeDifference(nextAppointment.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentHistoryScreen(),
                  ),
                );
              },
            ),
          );
        } else if (state is AppointmentFailed) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<AppointmentBloc>().add(
                          LoadAppointments(
                            uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                        );
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text("No appointments available."));
        }
      },
    );
  }

  String _formatTimeDifference(DateTime appointmentDate) {
    final now = DateTime.now();
    final difference = appointmentDate.difference(now);

    if (difference.inMinutes < 60) {
      return "In ${difference.inMinutes} minutes";
    } else if (difference.inHours < 24) {
      return "In ${difference.inHours} hours";
    } else {
      return "In ${difference.inDays} days";
    }
  }

  Widget _buildMedicationBar(Medication medication) {
    String statusText;
    Color statusColor;

    if (medication.isTaken) {
      statusText = 'Taken';
      statusColor = Colors.green;
    } else if (medication.isMissed) {
      statusText = 'Missed';
      statusColor = Colors.red;
    } else {
      statusText = 'Upcoming';
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.green),
        title: const Text("Med-Notifier"),
        subtitle: Text(
          "${medication.name} - ${DateFormat.jm().format(medication.time)}",
        ),
        trailing: Chip(
          label: Text(statusText),
          backgroundColor: statusColor.withOpacity(0.2),
          labelStyle: TextStyle(color: statusColor),
        ),
        onTap: () {
          // Navigate to the medication details screen
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicationScreen(
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              ));
        },
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final isWide = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      itemCount: features.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => feature['screen']),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black45 : Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          feature['icon'],
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['title'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: isDark ? Colors.white : Colors.black, // Explicitly handle color
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedTextKit(
          key: ValueKey(
              '$title-${isDark ? "dark" : "light"}'), // Ensure it retriggers on theme change
          isRepeatingAnimation: true,
          animatedTexts: [
            TyperAnimatedText(
              title,
              speed: const Duration(milliseconds: 200),
              textStyle: titleStyle!,
            ),
          ],
          totalRepeatCount: 1,
          pause: const Duration(milliseconds: 100),
          displayFullTextOnTap: true,
          stopPauseOnTap: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFeaturesBasedOnGender(); // Load features based on gender when HomeScreen initializes
  }
}
