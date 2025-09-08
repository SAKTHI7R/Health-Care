import 'dart:ui';
import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String weatherCondition;
  final bool isDark;

  const WeatherCard({
    Key? key,
    required this.weatherCondition,
    this.isDark = false,
  }) : super(key: key);

  IconData _getWeatherIcon(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('sun') || cond.contains('clear')) {
      return Icons.wb_sunny_rounded;
    } else if (cond.contains('cloud')) {
      return Icons.wb_cloudy_rounded;
    } else if (cond.contains('rain') || cond.contains('shower')) {
      return Icons.grain_rounded;
    } else if (cond.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (cond.contains('storm') || cond.contains('thunder')) {
      return Icons.flash_on_rounded;
    } else if (cond.contains('fog') ||
        cond.contains('mist') ||
        cond.contains('haze')) {
      return Icons.blur_on_rounded;
    } else {
      return Icons.wb_sunny_rounded;
    }
  }

  List<Color> _getGradientColors() {
    return isDark
        ? [
            const Color(0xFF0F2027),
            const Color(0xFF203A43),
            const Color(0xFF2C5364),
          ]
        : [
            Colors.white.withOpacity(0.6),
            Colors.blue.shade100.withOpacity(0.3),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.blue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Blur Layer (Glass Effect)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _getWeatherIcon(weatherCondition),
                      size: 42,
                      color: isDark ? Colors.white : Colors.blueGrey.shade800,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weather',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weatherCondition,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
