import 'hourly_data.dart';
import 'daily_forecast.dart';

class Weather {
  final String cityName;

  final double temperature;
  final String description;

  final int rainChance;
  final int humidity;

  final double feelsLike;
  final double windSpeed;

  final List<HourlyData> hourly;

  final List<DailyForecast> weekly;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.rainChance,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.hourly,
    required this.weekly,
  });

  bool get isRainy => rainChance >= 70;

  bool get isHot => temperature >= 30;

  bool get isCold => temperature <= 18;
}