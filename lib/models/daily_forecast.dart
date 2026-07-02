class DailyForecast {
  final String day;
  final double maxTemp;
  final double minTemp;
  final int rainChance;

  const DailyForecast({
    required this.day,
    required this.maxTemp,
    required this.minTemp,
    required this.rainChance,
  });
}