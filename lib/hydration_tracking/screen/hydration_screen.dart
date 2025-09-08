import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/hydration_bloc.dart';
import '../bloc/hydration_event.dart';
import '../bloc/hydration_state.dart';

import '../notification.dart';
import '../repository/hydration_repository.dart';
import '../widget/reminder_settings.dart';
import '../widget/water_chart.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<WaterRepository>();
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 Hydration Tracker'),
        centerTitle: true,
      ),
      body: BlocBuilder<WaterBloc, WaterState>(
        builder: (context, state) {
          if (state is WaterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WaterLoaded) {
            final progress = state.intake / state.goal;
            return Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: SizedBox(
                            key: ValueKey(progress),
                            width: isSmallScreen ? 120 : 150,
                            height: isSmallScreen ? 120 : 150,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${state.intake} ml',
                                style: theme.textTheme.headlineSmall),
                            Text('of ${state.goal} ml',
                                style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<WaterBloc>().add(AddWater(250));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('+250 ml added!')),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('+250ml'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<WaterBloc>().add(AddWater(-500));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('+500 ml added!')),
                          );
                        },
                        icon: const Icon(Icons.local_drink),
                        label: const Text('+500ml'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await notificationService.init();
                          notificationService.showImmediateHydrationReminder();
                        },
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Hydrate Now'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          context.read<WaterBloc>().add(ResetIntake());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Intake reset to 0 ml')),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 10),
                  Text('Water Intake Log', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: repository.getTodayLogsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final entries = snapshot.data?.docs ?? [];
                        if (entries.isEmpty) {
                          return const Center(child: Text('No entries yet.'));
                        }
                        return ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final data =
                                entries[index].data() as Map<String, dynamic>;
                            final time =
                                (data['timestamp'] as Timestamp).toDate();
                            final ml = data['ml'];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.local_drink_outlined),
                                title: Text('$ml ml',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                                subtitle:
                                    Text(DateFormat('hh:mm a').format(time)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Chart', style: theme.textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Goal',
                        onPressed: () async {
                          final controller = TextEditingController();
                          // ignore: unused_local_variable
                          final newGoal = await showDialog<int>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Daily Goal'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'Enter goal in ml'),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                ElevatedButton(
                                  child: const Text('Save'),
                                  onPressed: () {
                                    final value = int.tryParse(controller.text);
                                    if (value != null && value > 0) {
                                      context
                                          .read<WaterBloc>()
                                          .add(UpdateGoal(value));
                                      Navigator.pop(context, value);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Goal updated!')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                      height: isSmallScreen ? 120 : 150, child: WaterChart()),
                  const SizedBox(height: 20),
                  ReminderSettingsTile(
                    remindersEnabled: state.remindersEnabled,
                    intervalMinutes: state.intervalMinutes,
                  ),
                ],
              ),
            );
          } else if (state is WaterError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
