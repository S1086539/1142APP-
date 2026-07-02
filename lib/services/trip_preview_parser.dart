import '../models/trip_preview.dart';

class TripPreviewParser {
  static TripPreview? build({
    required String? destinationCity,
    required String? latestUserText,
    required String? latestAIText,
  }) {
    if (destinationCity == null) {
      return null;
    }

    if (latestAIText == null || latestAIText.trim().isEmpty) {
      return null;
    }

    final dayCount = _parseDayCount(latestUserText ?? latestAIText);
    final days = _extractDays(latestAIText);
    final highlights = _extractHighlights(
      aiText: latestAIText,
      destinationCity: destinationCity,
      days: days,
    );
    final weatherNote = _extractWeatherNote(latestAIText);

    return TripPreview(
      title: _buildTitle(destinationCity, dayCount),
      destinationCity: destinationCity,
      dayCount: dayCount,
      highlights: highlights,
      weatherNote: weatherNote,
      days: days,
    );
  }

  static String _buildTitle(
      String destinationCity,
      int dayCount,
      ) {
    if (dayCount <= 1) {
      return '$destinationCity 一日行程預覽';
    }

    return '$destinationCity $dayCount 天行程預覽';
  }

  static int _parseDayCount(String text) {
    if (text.contains('五天') ||
        text.contains('5天') ||
        text.contains('五日') ||
        text.contains('5日')) {
      return 5;
    }

    if (text.contains('四天') ||
        text.contains('4天') ||
        text.contains('四日') ||
        text.contains('4日')) {
      return 4;
    }

    if (text.contains('三天') ||
        text.contains('3天') ||
        text.contains('三日') ||
        text.contains('3日')) {
      return 3;
    }

    if (text.contains('兩天') ||
        text.contains('二天') ||
        text.contains('2天') ||
        text.contains('兩日') ||
        text.contains('二日') ||
        text.contains('2日')) {
      return 2;
    }

    return 1;
  }

  static List<TripPreviewDay> _extractDays(String aiText) {
    final lines = aiText
        .split('\n')
        .map(_cleanLine)
        .where((line) => line.isNotEmpty)
        .toList();

    final dayMap = <int, List<TripPreviewTimeSlot>>{};

    int currentDay = 1;

    final dayPattern = RegExp(
      r'^(Day\s*(\d+)|第\s*([一二三四五六七八九十\d]+)\s*天)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final dayMatch = dayPattern.firstMatch(line);

      if (dayMatch != null) {
        final numberText = dayMatch.group(2) ?? dayMatch.group(3) ?? '1';
        currentDay = _parseChineseOrArabicNumber(numberText);
        dayMap.putIfAbsent(currentDay, () => []);
        continue;
      }

      final slot = _parseTimeSlot(line);

      if (slot != null) {
        dayMap.putIfAbsent(currentDay, () => []);
        dayMap[currentDay]!.add(slot);
      }
    }

    return dayMap.entries
        .where((entry) => entry.value.isNotEmpty)
        .map(
          (entry) => TripPreviewDay(
        dayNumber: entry.key,
        slots: entry.value,
      ),
    )
        .toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  static TripPreviewTimeSlot? _parseTimeSlot(String line) {
    final pattern = RegExp(
      r'^(上午|早上|中午|下午|傍晚|晚上|夜晚)\s*[:：]\s*(.+)$',
    );

    final match = pattern.firstMatch(line);

    if (match == null) {
      return null;
    }

    final period = match.group(1) ?? '';
    final content = match.group(2)?.trim() ?? '';

    if (content.isEmpty) {
      return null;
    }

    final parts = content.split(RegExp(r'[，,。]'));
    final place = parts.first.trim();

    final description = parts.length > 1
        ? parts.skip(1).join('，').trim()
        : '';

    return TripPreviewTimeSlot(
      period: period,
      place: place,
      description: description,
    );
  }

  static List<String> _extractHighlights({
    required String aiText,
    required String destinationCity,
    required List<TripPreviewDay> days,
  }) {
    final fromDays = days
        .expand((day) => day.slots)
        .map((slot) => slot.displayText)
        .where((text) => text.trim().isNotEmpty)
        .take(5)
        .toList();

    if (fromDays.isNotEmpty) {
      return fromDays;
    }

    final result = <String>[];

    final lines = aiText
        .split('\n')
        .map(_cleanLine)
        .where((line) => line.isNotEmpty)
        .toList();

    final timePattern = RegExp(
      r'^(上午|早上|中午|下午|傍晚|晚上|夜晚)\s*[:：]\s*',
    );

    for (final line in lines) {
      if (timePattern.hasMatch(line)) {
        final cleaned = line.replaceFirst(timePattern, '').trim();

        if (cleaned.isNotEmpty) {
          result.add(cleaned);
        }
      }
    }

    if (result.isNotEmpty) {
      return result.take(5).toList();
    }

    return _fallbackHighlights(destinationCity);
  }

  static String _extractWeatherNote(String aiText) {
    final lines = aiText
        .split('\n')
        .map(_cleanLine)
        .where((line) => line.isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      final isWeatherTitle = line.contains('天氣提醒') ||
          line.contains('天氣建議') ||
          line.contains('降雨') ||
          line.contains('備案建議');

      if (!isWeatherTitle) {
        continue;
      }

      final sameLineParts = line.split(RegExp(r'[:：]'));

      if (sameLineParts.length >= 2) {
        final sameLineContent = sameLineParts.skip(1).join('：').trim();

        if (sameLineContent.isNotEmpty) {
          return sameLineContent;
        }
      }

      if (i + 1 < lines.length) {
        return lines[i + 1];
      }
    }

    return 'AI 將會依照目的地天氣，協助調整戶外與室內行程安排。';
  }

  static List<String> _fallbackHighlights(String destinationCity) {
    if (destinationCity == '花蓮縣') {
      return [
        '七星潭海岸',
        '松園別館',
        '東大門夜市',
        '太魯閣或鯉魚潭',
      ];
    }

    if (destinationCity == '宜蘭縣') {
      return [
        '幾米公園',
        '宜蘭市區小吃',
        '羅東林業文化園區',
        '礁溪溫泉',
      ];
    }

    if (destinationCity == '臺南市') {
      return [
        '赤崁樓',
        '國華街美食',
        '孔廟與林百貨',
        '神農街或夜市',
      ];
    }

    if (destinationCity == '臺中市') {
      return [
        '審計新村',
        '草悟道',
        '宮原眼科',
        '逢甲夜市',
      ];
    }

    return [
      '城市散步',
      '在地美食',
      '特色景點',
      '雨天備案',
    ];
  }

  static String _cleanLine(String line) {
    return line
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('-', '')
        .replaceAll('`', '')
        .replaceAll('•', '')
        .trim();
  }

  static int _parseChineseOrArabicNumber(String value) {
    final trimmed = value.trim();

    final parsed = int.tryParse(trimmed);

    if (parsed != null) {
      return parsed;
    }

    const map = {
      '一': 1,
      '二': 2,
      '兩': 2,
      '三': 3,
      '四': 4,
      '五': 5,
      '六': 6,
      '七': 7,
      '八': 8,
      '九': 9,
      '十': 10,
    };

    return map[trimmed] ?? 1;
  }
}