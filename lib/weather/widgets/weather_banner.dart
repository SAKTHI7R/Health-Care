import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

class WeatherBanner extends StatefulWidget {
  final String city;
  const WeatherBanner({super.key, required this.city});

  @override
  State<WeatherBanner> createState() => _WeatherBannerState();
}

class _WeatherBannerState extends State<WeatherBanner> {
  late TextEditingController _cityController;
  late String city;
  bool _isFetchingLocation = false;
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.city);

    if (widget.city.isNotEmpty) {
      _getWeather(widget.city);
    } else {
      _getLocationWeather();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _getWeather(String city) async {
    context.read<WeatherBloc>().add(FetchWeather(city, isCelsius: _isCelsius));
  }

  Future<void> _getLocationWeather() async {
    setState(() => _isFetchingLocation = true);

    try {
      // Step 1: Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services are disabled.");
        return;
      }

      // Step 2: Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint("Location permission denied.");
        return;
      }

      // Step 3: Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint("Position: ${position.latitude}, ${position.longitude}");

      // Step 4: Convert to placemark (city name)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        String? city = placemarks.first.locality;
        if (city != null && city.isNotEmpty) {
          _cityController.text = city;
          debugPrint("Detected city: $city");
          _getWeather(city);
        } else {
          debugPrint("City not found in placemarks.");
        }
      } else {
        debugPrint("No placemarks found.");
      }
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  void _toggleUnit() {
    setState(() => _isCelsius = !_isCelsius);
    _getWeather(_cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        Widget weatherWidget;

        if (state is WeatherLoading) {
          weatherWidget = Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                backgroundColor: Colors.blue,
              ),
            ),
          );
        } else if (state is WeatherLoaded) {
          final weather = state.weather;

          weatherWidget = AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 800),
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.grey[850]!, Colors.blue[900]!]
                      : [Colors.blue.shade100, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          _getIcon(weather.condition),
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${weather.condition} • ${weather.temperature}°${_isCelsius ? 'C' : 'F'}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.sync_alt),
                        onPressed: _toggleUnit,
                        tooltip: 'Toggle °C/°F',
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: isDark ? Colors.white : Colors.blue,
                        iconSize: 30,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _weatherDetailTile(
                          Icons.opacity, "${weather.humidity}%", "Humidity"),
                      _weatherDetailTile(
                          Icons.air, "${weather.windSpeed} km/h", "Wind"),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (state is WeatherError) {
          weatherWidget = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(state.message, style: TextStyle(color: Colors.red)),
          );
        } else {
          weatherWidget = SizedBox.shrink();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Search for a city...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _getWeather(_cityController.text),
                      ),
                      IconButton(
                        icon: _isFetchingLocation
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.my_location),
                        onPressed: _getLocationWeather,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            weatherWidget,
          ],
        );
      },
    );
  }

  Widget _weatherDetailTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  IconData _getIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun')) return Icons.wb_sunny_rounded;
    if (lower.contains('rain')) return Icons.beach_access_rounded;
    if (lower.contains('cloud')) return Icons.cloud;
    if (lower.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }
}
