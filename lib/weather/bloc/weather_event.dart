abstract class WeatherEvent {}

class FetchWeather extends WeatherEvent {
  final String city;
  final bool isCelsius;

  FetchWeather(this.city, {this.isCelsius = true});
}

class ToggleUnit extends WeatherEvent {}
