import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';
import '../model/medication_model.dart';

class MedicationScreen extends StatelessWidget {
  final String userId;

  const MedicationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationBloc, MedicationState>(
      listener: (context, state) {
        if (state is MedicationLoaded && state.medications.isEmpty) {
          _openAddEditDialog(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Medications')),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _openAddEditDialog(context),
        ),
        body: BlocBuilder<MedicationBloc, MedicationState>(
          builder: (context, state) {
            if (state is MedicationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedicationLoaded) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return ListView.builder(
                    itemCount: state.medications.length,
                    itemBuilder: (context, index) {
                      final med = state.medications[index];
                      final now = DateTime.now();
                      final isMissed = now.isAfter(med.time) && !med.isTaken;

                      Color cardColor = isMissed
                          ? Colors.red.shade50
                          : med.isTaken
                              ? Colors.green.shade50
                              : Colors.blue.shade50;

                      IconData statusIcon = isMissed
                          ? Icons.warning_amber
                          : med.isTaken
                              ? Icons.check_circle
                              : Icons.access_time;

                      Color statusColor = isMissed
                          ? Colors.redAccent
                          : med.isTaken
                              ? Colors.green
                              : Colors.blue;

                      // Slidable for swipe actions (edit, delete)
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Slidable(
                          key: ValueKey(med.id),
                          startActionPane: ActionPane(
                            motion:
                                const BehindMotion(), // smoother than DrawerMotion
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (_) =>
                                    _openAddEditDialog(context, med),
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                                borderRadius: BorderRadius.circular(12),
                                spacing: 4,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(), // clean slide
                            extentRatio: 0.3,
                            children: [
                              SlidableAction(
                                onPressed: (_) => _confirmDelete(context, med),
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_forever,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(12),
                                spacing: 4,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.black12,
                            color: cardColor,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              leading: CircleAvatar(
                                backgroundColor: statusColor,
                                child: Icon(statusIcon, color: Colors.white),
                              ),
                              title: Text(
                                med.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Icon(Icons.schedule,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat.jm().format(med.time),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 10),
                                      if (isMissed)
                                        Chip(
                                          label: const Text('Missed',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          backgroundColor: Colors.redAccent,
                                          visualDensity: VisualDensity.compact,
                                        )
                                      else if (med.isTaken)
                                        Chip(
                                          label: const Text('Taken',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          backgroundColor: Colors.green,
                                          visualDensity: VisualDensity.compact,
                                        )
                                      else
                                        Chip(
                                          label: const Text('Pending',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          backgroundColor: Colors.blueAccent,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  )),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      med.isAlertEnabled
                                          ? Icons.notifications_active
                                          : Icons.notifications_off,
                                      color: med.isAlertEnabled
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      context.read<MedicationBloc>().add(
                                          ToggleAlert(
                                              med.id, !med.isAlertEnabled));
                                    },
                                    tooltip: 'Toggle Alert',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Checkbox(
                                    value: med.isTaken,
                                    onChanged: (value) {
                                      context
                                          .read<MedicationBloc>()
                                          .add(MarkTaken(med.id, value!));
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              onTap: () => _openAddEditDialog(context, med),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _openAddEditDialog(BuildContext context, [Medication? med]) {
    final List<String> commonMedications = [
      'Paracetamol',
      'Ibuprofen',
      'Amoxicillin',
      'Aspirin',
      'Metformin',
      'Atorvastatin',
      'Omeprazole',
      'Ciprofloxacin',
      'Cetirizine',
      'Vitamin D',
      'Other',
    ];

    String selectedMedication = med?.name ?? commonMedications.first;
    final TextEditingController customNameController = TextEditingController();
    DateTime selectedTime =
        med?.time ?? DateTime.now().add(const Duration(minutes: 5));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isOther = selectedMedication == 'Other';

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(med == null ? 'Add Medication' : 'Edit Medication'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: commonMedications.contains(selectedMedication)
                        ? selectedMedication
                        : 'Other',
                    items: commonMedications.map((medName) {
                      return DropdownMenuItem(
                        value: medName,
                        child: Text(medName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMedication = value!;
                        if (value != 'Other') {
                          customNameController.clear();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Medication',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isOther)
                    TextField(
                      controller: customNameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(DateFormat.jm().format(selectedTime)),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedTime),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = DateTime(
                            selectedTime.year,
                            selectedTime.month,
                            selectedTime.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final medName = selectedMedication == 'Other'
                        ? customNameController.text.trim()
                        : selectedMedication;

                    if (medName.isEmpty) return;

                    Navigator.pop(context);
                    context.read<MedicationBloc>().add(
                          AddOrEditMedication(
                            Medication(
                              id: med?.id ?? '',
                              name: medName,
                              time: selectedTime,
                              isAlertEnabled: true,
                              isTaken: false,
                              isActive: false,
                              isMissed: false,
                            ),
                          ),
                        );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Medication?'),
        content: Text('Are you sure you want to delete "${med.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              context.read<MedicationBloc>().add(DeleteMedication(med.id));

              // Undo SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${med.name}" deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      context
                          .read<MedicationBloc>()
                          .add(AddOrEditMedication(med));
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
