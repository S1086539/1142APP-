import 'weather.dart';

class AITripPromptContext {
  final String userText;
  final String? destinationCity;
  final Weather? destinationWeather;
  final String conversationHistoryText;
  final String prompt;

  const AITripPromptContext({
    required this.userText,
    required this.destinationCity,
    required this.destinationWeather,
    required this.prompt,
    this.conversationHistoryText = '',
  });

  bool get hasDestination {
    return destinationCity != null && destinationCity!.trim().isNotEmpty;
  }

  bool get hasWeather {
    return destinationWeather != null;
  }

  bool get hasConversationHistory {
    return conversationHistoryText.trim().isNotEmpty;
  }

  String get weatherSummary {
    final weather = destinationWeather;

    if (weather == null) {
      return '目前尚未取得目的地天氣資料。';
    }

    return '${weather.cityName}目前約${weather.temperature.toStringAsFixed(0)}°，'
        '${weather.description}，'
        '降雨機率${weather.rainChance}%，'
        '體感溫度${weather.feelsLike.toStringAsFixed(0)}°，'
        '濕度${weather.humidity}%。';
  }
}