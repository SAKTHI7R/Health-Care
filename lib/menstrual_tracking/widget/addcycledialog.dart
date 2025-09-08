import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/menstrual_bloc.dart';
import '../bloc/menstrual_event.dart';

class AddCycleDialog extends StatefulWidget {
  const AddCycleDialog({super.key});

  @override
  State<AddCycleDialog> createState() => _AddCycleDialogState();
}

class _AddCycleDialogState extends State<AddCycleDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _cycleLength = 28;

  final _formKey = GlobalKey<FormState>();

  Future<void> _submitCycle() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both dates")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('menstrual')
        .doc('cycle');

    await docRef.set({
      'startDate': _startDate,
      'endDate': _endDate,
      'cycleLength': _cycleLength,
    });

    if (mounted) {
      context.read<MenstrualBloc>().add(LoadCycleData(uid));
      Navigator.pop(context); // Close the dialog
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Add Menstrual Cycle"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_startDate == null
                    ? "Pick Start Date"
                    : "Start: ${_startDate!.toLocal().toString().split(' ')[0]}"),
                onPressed: () => _pickDate(isStart: true),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_endDate == null
                    ? "Pick End Date"
                    : "End: ${_endDate!.toLocal().toString().split(' ')[0]}"),
                onPressed: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Cycle Length:"),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: _cycleLength.toDouble(),
                      min: 20,
                      max: 40,
                      divisions: 20,
                      label: "$_cycleLength days",
                      onChanged: (val) {
                        setState(() {
                          _cycleLength = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submitCycle,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
