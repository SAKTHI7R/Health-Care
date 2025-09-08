import 'package:flutter/material.dart';
import 'dart:async';

import 'appointment_screen.dart';

class DoctorSearchScreen extends StatefulWidget {
  @override
  _DoctorSearchScreenState createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, String>> doctors = [
    {
      "name": "Dr. John Doe",
      "specialty": "Cardiologist",
      "location": "New York",
      "rating": "4.8",
      "image": "assets/doctor1.jpg"
    },
    {
      "name": "Dr. Alice Smith",
      "specialty": "Dermatologist",
      "location": "Los Angeles",
      "rating": "4.7",
      "image": "assets/doctor2.jpg"
    },
    {
      "name": "Dr. Michael Brown",
      "specialty": "Pediatrician",
      "location": "Chicago",
      "rating": "4.9",
      "image": "assets/doctor3.jpeg"
    },
    {
      "name": "Dr. Emma Wilson",
      "specialty": "Neurologist",
      "location": "Houston",
      "rating": "4.6",
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
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        filteredDoctors = doctors
            .where((doctor) =>
                doctor["name"]!.toLowerCase().contains(query.toLowerCase()) ||
                doctor["specialty"]!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                doctor["location"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  void _navigateToDoctorProfile(Map<String, String> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorProfileScreen(doctor: doctor),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Find Your Doctor"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blueAccent,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by name, specialty, or location",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.blue[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchDoctor,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                var doctor = filteredDoctors[index];
                return GestureDetector(
                  onTap: () => _navigateToDoctorProfile(doctor),
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Hero(
                            tag: doctor["image"]!,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(doctor["image"]!),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor["name"]!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${doctor["specialty"]} • ${doctor["location"]}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              SizedBox(width: 4),
                              Text(
                                doctor["rating"]!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class DoctorProfileScreen extends StatelessWidget {
  final Map<String, String> doctor;

  DoctorProfileScreen({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(doctor["name"]!),
        //backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: doctor["name"]!,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(doctor["image"]!),
              ),
            ),
            SizedBox(height: 20),
            Text(
              doctor["name"]!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              doctor["specialty"]!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  doctor["location"]!,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 30),
                SizedBox(width: 8),
                Text(
                  doctor["rating"]!,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentBookingScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
              ),
              child: Text(
                "Book Appointment",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
