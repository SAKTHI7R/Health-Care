import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
//import 'package:url_launcher/url_launcher.dart';

import 'emergency_helper.dart';

class HospitalMapScreen extends StatefulWidget {
  @override
  _HospitalMapScreenState createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final MapController mapController = MapController();
  LocationData? userLocation;
  LatLng? hospitalLatLng;
  String? hospitalName;
  bool isLoading = true;
  late final StreamSubscription<LocationData> locationSubscription;
  bool userMovedMap = false;
  bool showHospitalInfo = true;
  @override
  void initState() {
    super.initState();
    loadMapData();

    mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        userMovedMap = true;
      }
    });

    final location = Location();
    locationSubscription = location.onLocationChanged.listen((loc) {
      setState(() {
        userLocation = loc;
      });

      if (!userMovedMap && loc.latitude != null && loc.longitude != null) {
        mapController.move(LatLng(loc.latitude!, loc.longitude!), 14);
      }
    });
  }

  Future<void> loadMapData() async {
    Location location = Location();

    if (!await location.serviceEnabled() && !await location.requestService()) {
      setState(() => isLoading = false);
      return;
    }

    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      setState(() => isLoading = false);
      return;
    }

    final loc = await location.getLocation();
    if (loc.latitude != null && loc.longitude != null) {
      final userLatLng = LatLng(loc.latitude!, loc.longitude!);
      final hospitals = await EmergencyHelper.getNearbyHospitals(
          loc.latitude!, loc.longitude!);

      if (hospitals.isNotEmpty) {
        final Distance distance = Distance();
        hospitals.sort((a, b) {
          final distA = distance(
            userLatLng,
            LatLng(double.parse(a['lat']), double.parse(a['lon'])),
          );
          final distB = distance(
            userLatLng,
            LatLng(double.parse(b['lat']), double.parse(b['lon'])),
          );
          return distA.compareTo(distB);
        });

        final nearest = hospitals.first;

        setState(() {
          userLocation = loc;
          hospitalLatLng = LatLng(
              double.parse(nearest['lat']), double.parse(nearest['lon']));
          hospitalName = nearest['display_name'];
          isLoading = false;
        });

        mapController.move(userLatLng, 14);
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Nearest Hospital'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (userLocation == null || hospitalLatLng == null)
            Center(child: Text('Unable to find nearby hospital.'))
          else
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  userLocation!.latitude!,
                  userLocation!.longitude!,
                ),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                          userLocation!.latitude!, userLocation!.longitude!),
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: "You are here",
                        child: Icon(Icons.person_pin_circle,
                            color: Colors.blueAccent, size: 40),
                      ),
                    ),
                    Marker(
                      point: hospitalLatLng!,
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: "Nearest Hospital",
                        child: Icon(Icons.local_hospital,
                            color: Colors.redAccent, size: 40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (hospitalName != null)
            if (hospitalName != null && showHospitalInfo)
              Positioned(
                left: 16,
                right: 16,
                bottom: 380,
                child: AnimatedOpacity(
                  opacity: showHospitalInfo ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Card(
                        color: Colors.white.withOpacity(0.2),
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_hospital,
                                      color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text("Nearest Hospital",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87)),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.close_rounded,
                                        color: Colors.black54),
                                    onPressed: () {
                                      setState(() {
                                        showHospitalInfo = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey.shade300),
                              Text(
                                hospitalName!,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Tooltip(
            message: "Toggle Hospital Info",
            child: FloatingActionButton(
              heroTag: "toggle_info",
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() => showHospitalInfo = !showHospitalInfo);
              },
              child: Icon(
                showHospitalInfo ? Icons.visibility_off : Icons.visibility,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 12),
          Tooltip(
            message: "Call Emergency (108)",
            child: FloatingActionButton(
              heroTag: "emergency",
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                await EmergencyHelper.emergencyCall();
              },
              child: Icon(Icons.phone_in_talk_rounded, size: 28),
            ),
          ),
          SizedBox(height: 12),
          Tooltip(
            message: "Recenter to Hospital",
            child: FloatingActionButton(
              heroTag: "hospital",
              backgroundColor: Colors.white,
              onPressed: () {
                if (hospitalLatLng != null) {
                  mapController.move(hospitalLatLng!, 16);
                }
              },
              child: Icon(Icons.local_hospital, color: Colors.redAccent),
            ),
          ),
          SizedBox(height: 12),
          Tooltip(
            message: "Recenter to You",
            child: FloatingActionButton(
              heroTag: "user",
              backgroundColor: Colors.white,
              onPressed: () {
                if (userLocation != null) {
                  mapController.move(
                    LatLng(userLocation!.latitude!, userLocation!.longitude!),
                    16,
                  );
                  userMovedMap = false;
                }
              },
              child: Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
          SizedBox(height: 12),
          Tooltip(
            message: "Refresh Nearby Hospitals",
            child: FloatingActionButton(
              heroTag: "refresh",
              backgroundColor: Colors.white,
              onPressed: () async {
                setState(() => isLoading = true);
                await loadMapData();
              },
              child: Icon(Icons.refresh, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
