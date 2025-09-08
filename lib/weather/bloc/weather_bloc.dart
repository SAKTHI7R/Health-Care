import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care/weather/model/weather.dart';
import 'package:http/http.dart' as http;

import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  bool isCelsius = true;

  WeatherBloc() : super(WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<ToggleUnit>(_onToggleUnit);
  }

  Future<void> _onFetchWeather(
      FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    isCelsius = event.isCelsius;

    try {
      final response = await http.get(
        Uri.parse('https://wttr.in/${event.city}?format=j1'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final weather = Weather.fromJson(jsonData, isCelsius: isCelsius);
        emit(WeatherLoaded(weather));
      } else {
        emit(WeatherError("Failed to fetch weather"));
      }
    } catch (e) {
      emit(WeatherError("Something went wrong: $e"));
    }
  }

  Future<void> _onToggleUnit(
      ToggleUnit event, Emitter<WeatherState> emit) async {
    if (state is WeatherLoaded) {
      final currentWeather = (state as WeatherLoaded).weather;
      add(FetchWeather(currentWeather.condition, isCelsius: !isCelsius));
    }
  }
}
