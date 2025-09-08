import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyHelper {
  /// Get user's current location
  static Future<LocationData?> getUserLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return null;
    }

    return await location.getLocation();
  }

  /// Fetch the nearest hospital using OpenStreetMap Nominatim
  static Future<List<Map<String, dynamic>>> getNearbyHospitals(
      double latitude, double longitude) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json'
      '&q=hospital&limit=10&extratags=1&bounded=1'
      '&viewbox=${longitude - 0.05},${latitude + 0.05},'
      '${longitude + 0.05},${latitude - 0.05}',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'FlutterApp/1.0 (youremail@example.com)'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<void> emergencyCall() async {
    final Uri telUri = Uri(scheme: 'tel', path: '108');

    if (!await launchUrl(telUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $telUri';
    }
  }
}
