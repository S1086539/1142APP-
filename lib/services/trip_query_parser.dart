class TripQueryParser {
  static const Map<String, String> _cityKeywordMap = {
    '台北': '臺北市',
    '臺北': '臺北市',
    '新北': '新北市',
    '桃園': '桃園市',
    '台中': '臺中市',
    '臺中': '臺中市',
    '台南': '臺南市',
    '臺南': '臺南市',
    '高雄': '高雄市',
    '基隆': '基隆市',
    '新竹': '新竹市',
    '嘉義': '嘉義市',
    '苗栗': '苗栗縣',
    '彰化': '彰化縣',
    '南投': '南投縣',
    '雲林': '雲林縣',
    '屏東': '屏東縣',
    '宜蘭': '宜蘭縣',
    '花蓮': '花蓮縣',
    '台東': '臺東縣',
    '臺東': '臺東縣',
    '澎湖': '澎湖縣',
    '金門': '金門縣',
    '連江': '連江縣',
    '馬祖': '連江縣',
  };

  static String? parseDestinationCity(String text) {
    final normalized = text.trim().replaceAll('台', '臺');

    for (final entry in _cityKeywordMap.entries) {
      final keyword = entry.key.replaceAll('台', '臺');

      if (normalized.contains(keyword)) {
        return entry.value;
      }
    }

    return null;
  }

  static String? parseLatestDestinationCityFromTexts(
      Iterable<String> texts,
      ) {
    final list = texts.toList();

    for (int i = list.length - 1; i >= 0; i--) {
      final city = parseDestinationCity(list[i]);

      if (city != null) {
        return city;
      }
    }

    return null;
  }
}