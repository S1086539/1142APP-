import '../models/ai_trip_prompt_context.dart';
import '../models/weather.dart';

class AITripPromptBuilder {
  static AITripPromptContext build({
    required String userText,
    required String? destinationCity,
    required Weather? destinationWeather,
    required String conversationHistoryText,
  }) {
    final dayCount =
        _parseDayCount(userText) ?? _parseDayCount(conversationHistoryText) ?? 1;

    final weatherText = _buildWeatherText(destinationWeather);
    final dayTemplate = _buildDayTemplate(dayCount);

    final prompt = '''
你是一位專業的 AI 旅遊行程規劃助理。

請根據使用者需求、過去對話、目的地與天氣資訊，產生完整的旅遊行程。

重要規則：
1. 請使用繁體中文。
2. 請不要使用 Markdown 語法。
3. 不要使用 **、#、- 這類 Markdown 標記。
4. 請輸出純文字，方便手機 App 顯示。
5. 必須完整輸出 $dayCount 天行程，不可以只輸出 Day 1。
6. 每一天都要包含上午、中午、下午、晚上。
7. 每個時段都要有具體地點或活動。
8. 每個推薦地點後面都要附上一句簡短描述，讓使用者知道該地點可以做什麼。
9. 行程要考慮天氣、降雨機率、體感溫度與移動順序。
10. 若天氣不穩定，請加入室內備案。
11. 如果使用者表示不喜歡某個地點、想換掉某個景點、不要某類活動，請根據使用者需求主動替換成其他合適地點。
12. 替換景點時，要簡短說明為什麼改成新地點，例如更符合偏好、較適合雨天、距離較順路、較適合拍照或美食。
13. 如果使用者提出修改需求，請參考過去對話中的上一版行程，保留仍合適的部分，只調整不符合需求的地點。
14. 如果使用者沒有明確說明偏好，請選擇大眾接受度高、交通順、適合初次造訪的景點。
15. 回覆長度請控制在手機畫面容易閱讀的程度，但行程必須完整。
16. 每個時段必須獨立一行，不可以把多個時段合併在同一行。

過去對話與上一版行程：
${conversationHistoryText.trim().isEmpty ? '尚無過去對話。' : conversationHistoryText}

本次使用者需求：
$userText

解析出的目的地：
${destinationCity ?? '未明確提到目的地'}

目的地天氣：
$weatherText

請按照以下格式回答：

行程建議：
$dayTemplate

天氣提醒：
請根據目的地天氣，提醒使用者需要注意的事項。

備案建議：
如果遇到下雨、太熱或天氣不穩定，請提供替代方案。

如果這次使用者是在要求修改行程，請額外加入：

修改說明：
簡短說明你替換了哪些地點，以及替換原因。
''';

    return AITripPromptContext(
      userText: userText,
      destinationCity: destinationCity,
      destinationWeather: destinationWeather,
      conversationHistoryText: conversationHistoryText,
      prompt: prompt,
    );
  }

  static int? _parseDayCount(String text) {
    final normalized = text.trim();

    if (normalized.contains('五天') ||
        normalized.contains('5天') ||
        normalized.contains('五日') ||
        normalized.contains('5日')) {
      return 5;
    }

    if (normalized.contains('四天') ||
        normalized.contains('4天') ||
        normalized.contains('四日') ||
        normalized.contains('4日')) {
      return 4;
    }

    if (normalized.contains('三天') ||
        normalized.contains('3天') ||
        normalized.contains('三日') ||
        normalized.contains('3日')) {
      return 3;
    }

    if (normalized.contains('兩天') ||
        normalized.contains('二天') ||
        normalized.contains('2天') ||
        normalized.contains('兩日') ||
        normalized.contains('二日') ||
        normalized.contains('2日')) {
      return 2;
    }

    if (normalized.contains('一天') ||
        normalized.contains('一日') ||
        normalized.contains('1天') ||
        normalized.contains('1日') ||
        normalized.contains('一日遊')) {
      return 1;
    }

    return null;
  }

  static String _buildDayTemplate(int dayCount) {
    final buffer = StringBuffer();

    for (int i = 1; i <= dayCount; i++) {
      buffer.writeln('Day $i');
      buffer.writeln('上午：地點名稱，簡短描述這裡可以做什麼');
      buffer.writeln('中午：地點名稱，簡短描述這裡可以吃什麼或休息什麼');
      buffer.writeln('下午：地點名稱，簡短描述這裡可以做什麼');
      buffer.writeln('晚上：地點名稱，簡短描述這裡可以做什麼');

      if (i != dayCount) {
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }

  static String _buildWeatherText(Weather? weather) {
    if (weather == null) {
      return '尚未取得天氣資料。若無法取得天氣，請仍提供一般性的行程建議，並提醒使用者出發前再次確認天氣。';
    }

    return '''
城市：${weather.cityName}
目前溫度：${weather.temperature.toStringAsFixed(0)}°
天氣描述：${weather.description}
降雨機率：${weather.rainChance}%
體感溫度：${weather.feelsLike.toStringAsFixed(0)}°
濕度：${weather.humidity}%
風速：${weather.windSpeed.toStringAsFixed(1)} m/s
''';
  }
}