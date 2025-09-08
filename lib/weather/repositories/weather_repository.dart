import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/weather.dart';

class WeatherRepository {
  Future<Weather> fetchWeather(String city) async {
    final response =
        await http.get(Uri.parse('https://wttr.in/$city?format=j1'));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
