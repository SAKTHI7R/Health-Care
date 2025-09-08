class Weather {
  final String condition;
  final double temperature; // keep as number
  final int humidity;
  final double windSpeed;
  final bool isCelsius;

  Weather({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    this.isCelsius = true,
  });

  factory Weather.fromJson(Map<String, dynamic> json, {bool isCelsius = true}) {
    try {
      final current = json['current_condition'][0];

      return Weather(
        condition: current['weatherDesc'][0]['value'] ?? 'Unknown',
        temperature: double.tryParse(
                isCelsius ? current['temp_C'] : current['temp_F']) ??
            0.0,
        humidity: int.tryParse(current['humidity'] ?? '0') ?? 0,
        windSpeed:
            double.tryParse(current['windspeedKmph'] ?? '0')?.toDouble() ?? 0.0,
        isCelsius: isCelsius,
      );
    } catch (e) {
      throw FormatException('Invalid weather data: $e');
    }
  }

  String get formattedTemp => '$temperature°${isCelsius ? 'C' : 'F'}';
}
