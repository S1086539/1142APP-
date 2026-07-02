import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/weather.dart';
import '../services/weather_service.dart';

final weatherProvider = FutureProvider.family<Weather, String>((ref, city) async {
  return WeatherService().fetchWeather(city);
});