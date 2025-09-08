import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Appointment History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('appointments')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Appointments Found!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final appointments = snapshot.data!.docs;

          // Group appointments by doctor
          final Map<String, List<QueryDocumentSnapshot>> groupedByDoctor = {};

          for (var doc in appointments) {
            final doctorName = doc['doctorName'] ?? 'Unknown Doctor';
            if (!groupedByDoctor.containsKey(doctorName)) {
              groupedByDoctor[doctorName] = [];
            }
            groupedByDoctor[doctorName]!.add(doc);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: groupedByDoctor.entries.map((entry) {
              final doctorName = entry.key;
              final doctorAppointments = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...doctorAppointments.map((appointmentDoc) {
                    final appointmentData =
                        appointmentDoc.data() as Map<String, dynamic>;
                    final DateTime dateTime =
                        DateTime.parse(appointmentData['date']);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(DateFormat('yyyy-MM-dd').format(dateTime)),
                        subtitle: Text(DateFormat('hh:mm a').format(dateTime)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Appointment?'),
                                content: const Text(
                                    'Are you sure you want to delete this appointment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('appointments')
                                  .doc(appointmentDoc.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Appointment deleted successfully!')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
