import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../blocs/appointment/appointment_bloc.dart';
import '../blocs/appointment/appointment_event.dart';
import '../utils/notification_service.dart';
import 'appointment_histroy_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final List<Map<String, String>> doctors = [
    {
      "id": "1",
      "name": "Dr. John Doe",
      "specialty": "Cardiologist",
      "image": "assets/doctor1.jpg"
    },
    {
      "id": "2",
      "name": "Dr. Alice Smith",
      "specialty": "Dermatologist",
      "image": "assets/doctor2.jpg"
    },
    {
      "id": "3",
      "name": "Dr. Michael Brown",
      "specialty": "Pediatrician",
      "image": "assets/doctor3.jpeg"
    },
    {
      "id": "4",
      "name": "Dr. Emma Wilson",
      "specialty": "Neurologist",
      "image": "assets/doctor4.jpeg"
    },
  ];

  List<Map<String, String>> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  void _searchDoctor(String query) {
    setState(() {
      filteredDoctors = doctors
          .where((doctor) =>
              doctor["name"]!.toLowerCase().contains(query.toLowerCase()) ||
              doctor["specialty"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            colorScheme: ColorScheme.light(primary: Colors.blueAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
    Text(
      selectedDate != null
          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
          : 'No date selected',
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            colorScheme: ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
    Text(
      selectedTime != null
          ? selectedTime!.format(context) // nicely formatted like "9:30 AM"
          : 'No time selected',
    );
  }

  void _bookAppointment(
      BuildContext context, String doctorId, String doctorName) async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    final DateTime appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('appointments')
          .add({
        'uid': uid,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'date': appointmentDateTime.toIso8601String(),
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> appointments = prefs.getStringList("appointments") ?? [];

      Map<String, String> newAppointment = {
        "doctorId": doctorId,
        "doctorName": doctorName,
        "date": DateFormat('yyyy-MM-dd').format(appointmentDateTime),
        "time": selectedTime!.format(context),
      };

      appointments.add(jsonEncode(newAppointment));
      await prefs.setStringList("appointments", appointments);

      scheduleAppointmentReminder(doctorName, appointmentDateTime);

      context.read<AppointmentBloc>().add(LoadAppointments(uid: uid));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment successfully booked!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to book appointment: $e")),
      );
    }
  }

  void _showBookingBottomSheet(
      BuildContext context, String doctorId, String doctorName) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Book Appointment with\n$doctorName",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(selectedDate == null
                    ? "Select Date"
                    : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(selectedTime == null
                    ? "Select Time"
                    : selectedTime!.format(context)),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: selectedDate != null && selectedTime != null
                      ? Colors.blueAccent
                      : Colors.grey, // Disabled color
                ),
                onPressed: selectedDate != null && selectedTime != null
                    ? () {
                        Navigator.pop(context);
                        _bookAppointment(context, doctorId, doctorName);
                      }
                    : null, // Disabled
                child: const Text("Confirm Appointment",
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AppointmentHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by doctor name or specialty",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchDoctor,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      // backgroundColor: Colors.blueAccent,
                      backgroundImage: doctor["image"] != null
                          ? AssetImage(doctor["image"]!)
                          : null,
                      child: Text(
                        doctor["name"]![3],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      doctor["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(doctor["specialty"]!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showBookingBottomSheet(
                        context, doctor["id"]!, doctor["name"]!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
