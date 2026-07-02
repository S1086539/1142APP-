import 'package:dio/dio.dart';

import '../models/weather.dart';
import '../models/hourly_data.dart';
import '../models/daily_forecast.dart';
import '../core/utils/date_utils.dart';

class WeatherService{
  static const _baseUrl = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore';
  static const _apiKey = 'CWA-3EB622BD-C545-4762-993A-C87BE1010E33';

  static const Map<String, String> _threeDayForecastDataIdMap = {
    '宜蘭縣': 'F-D0047-001',
    '桃園市': 'F-D0047-005',
    '新竹縣': 'F-D0047-009',
    '苗栗縣': 'F-D0047-013',
    '彰化縣': 'F-D0047-017',
    '南投縣': 'F-D0047-021',
    '雲林縣': 'F-D0047-025',
    '嘉義縣': 'F-D0047-029',
    '屏東縣': 'F-D0047-033',
    '臺東縣': 'F-D0047-037',
    '花蓮縣': 'F-D0047-041',
    '澎湖縣': 'F-D0047-045',
    '基隆市': 'F-D0047-049',
    '新竹市': 'F-D0047-053',
    '嘉義市': 'F-D0047-057',
    '臺北市': 'F-D0047-061',
    '高雄市': 'F-D0047-065',
    '新北市': 'F-D0047-069',
    '臺中市': 'F-D0047-073',
    '臺南市': 'F-D0047-077',
    '連江縣': 'F-D0047-081',
    '金門縣': 'F-D0047-085',
  };

  late Dio _dio;

  WeatherService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
    ));
  }

  Future<List<HourlyData>> fetchHourlyForecast24(String city) async {
    final formattedCity = city.trim().replaceAll('台', '臺');

    final dataId = _threeDayForecastDataIdMap[formattedCity];

    if (dataId == null) {
      throw Exception('尚未支援 $formattedCity 的逐小時預報 DataId');
    }

    final res = await _dio.get(
      '/$dataId',
      queryParameters: {
        'Authorization': _apiKey,
        'format': 'JSON',
      },
    );

    final List locations = _extractLocationsFromHourlyResponse(res.data);

    final locationData = _pickDefaultTownshipLocation(
      locations: locations,
      city: formattedCity,
    );

    final elements = locationData['WeatherElement'] as List;

    final temperatureElement = elements.firstWhere(
          (e) => e['ElementName'] == '溫度',
    );

    dynamic weatherElement;

    try {
      weatherElement = elements.firstWhere(
            (e) => e['ElementName'] == '天氣現象',
      );
    } catch (_) {
      weatherElement = null;
    }

    final List temperatureTimes = temperatureElement['Time'] as List;
    final List weatherTimes =
    weatherElement == null ? [] : weatherElement['Time'] as List;

    final now = _nowInTaiwan();

    // 現在 02:11，從 03:00 開始
    final startHour = _nextHour(now);

    final List<HourlyData> result = [];

    for (final item in temperatureTimes) {
      final timeRaw = item['DataTime'] ?? item['StartTime'];

      if (timeRaw == null) {
        continue;
      }

      final time = _parseTaiwanTime(timeRaw.toString());

      if (time.isBefore(startHour)) {
        continue;
      }

      final tempRaw = _readElementValue(
        item,
        'Temperature',
        fallback: '0',
      );

      final weatherText = _findWeatherTextByTime(
        weatherTimes: weatherTimes,
        targetTime: time,
      );

      result.add(
        HourlyData(
          time: time,
          temperature: double.tryParse(tempRaw.toString()) ?? 0,
          weather: weatherText,
        ),
      );

      if (result.length >= 24) {
        break;
      }
    }

    if (result.isEmpty) {
      throw Exception('沒有取得 $formattedCity 未來 24 小時逐時溫度');
    }

    return result;
  }

  Future<Weather> fetchWeather(String city) async {
    final formattedCity = city.trim().replaceAll('台', '臺');
    print("正在請求氣象資料，城市名稱: $formattedCity");

    try {
      final res = await _dio.get('/F-D0047-091', queryParameters: {
        'Authorization': _apiKey,
        'locationName': formattedCity,
        'format': 'JSON',
      });

      final records = res.data['records'];
      if (records == null || records['Locations'] == null || records['Locations'].isEmpty) {
        throw "找不到資料結構";
      }

      final List locations = records['Locations'][0]['Location'];
      final locationData = locations.firstWhere(
            (l) => l['LocationName'] == formattedCity,
        orElse: () => throw "在資料集中找不到「$formattedCity」",
      );
      final elements = locationData['WeatherElement'] as List;

      // 基本天氣資訊解
      String temp = _dynamicGetVal(elements, '平均溫度', 'Temperature', 0);
      String description = _dynamicGetVal(elements, '天氣預報綜合描述', 'WeatherDescription', 0).split('。')[0];
      String rh = _dynamicGetVal(elements, '平均相對濕度', 'RelativeHumidity', 0);
      String ws = _dynamicGetVal(elements, '風速', 'WindSpeed', 0);

      String rain = "0";
      String descFull = _dynamicGetVal(elements, '天氣預報綜合描述', 'WeatherDescription', 0);
      RegExp rainReg = RegExp(r"降雨機率(\d+)%");
      if (rainReg.hasMatch(descFull)) {
        rain = rainReg.firstMatch(descFull)?.group(1) ?? "0";
      }

      // 每小時預報
      List<HourlyData> hourly = [];

      try {
        hourly = await fetchHourlyForecast24(formattedCity);
        print('逐小時預報成功：${hourly.length} 筆，第一筆 ${hourly.first.time}');
      } catch (e) {
        print("逐小時預報 API 讀取失敗，改用原本資料：$e");

        hourly = _buildHourlyFallbackFromWeeklyData(
          elements: elements,
          fallbackTemp: temp,
          fallbackDescription: description,
        );
      }

      // 一週預報
      List<DailyForecast> weekly = [];

      try {
        final maxTList = elements
            .firstWhere((e) => e['ElementName'] == '最高溫度')['Time'] as List;

        final minTList = elements
            .firstWhere((e) => e['ElementName'] == '最低溫度')['Time'] as List;

        final descList = elements
            .firstWhere((e) => e['ElementName'] == '天氣預報綜合描述')['Time'] as List;

        for (int i = 0; i < maxTList.length; i++) {
          String startTime = maxTList[i]['StartTime'];

          if (startTime.contains("06:00:00")) {

            DateTime date = DateTime.parse(startTime);

            String dayDesc =
                descList[i]['ElementValue'][0]['WeatherDescription'] ?? "";

            String dayRain =
                RegExp(r"降雨機率(\d+)%")
                    .firstMatch(dayDesc)
                    ?.group(1) ??
                    "0";

            final maxTemp =
            maxTList[i]['ElementValue'][0]['MaxTemperature'];

            final minTemp =
            (i < minTList.length)
                ? minTList[i]['ElementValue'][0]['MinTemperature']
                : "0";

            weekly.add(
              DailyForecast(
                day: getWeekDay(date),
                maxTemp: double.tryParse(maxTemp.toString()) ?? 0,
                minTemp: double.tryParse(minTemp.toString()) ?? 0,
                rainChance: int.tryParse(dayRain) ?? 0,
              ),
            );
          }
        }
      } catch (e) {
        print("週預報垂直列表解析出錯: $e");
      }

      return Weather(
        cityName: formattedCity,
        temperature: double.tryParse(temp) ?? 0.0,
        description: description,
        rainChance: int.tryParse(rain) ?? 0,
        humidity: int.tryParse(rh) ?? 0,
        feelsLike: double.tryParse(temp) ?? 0.0,
        windSpeed: double.tryParse(ws) ?? 0.0,
        hourly: hourly,
        weekly: weekly,
      );
    } catch (e) {
      print("解析錯誤細節: $e");
      throw "資料讀取失敗，請稍後再試";
    }
  }

  String _dynamicGetVal(List elements, String elementName, String valueKey, int timeIndex) {
    try {
      final el = elements.firstWhere((e) => e['ElementName'] == elementName);
      final val = el['Time'][timeIndex]['ElementValue'][0][valueKey];
      return val?.toString() ?? "0";
    } catch (e) {
      return "0";
    }
  }

  dynamic _readElementValue(
      dynamic item,
      String key, {
        dynamic fallback,
      }) {
    final elementValue = item['ElementValue'];

    if (elementValue is List && elementValue.isNotEmpty) {
      final first = elementValue.first;

      if (first is Map && first.containsKey(key)) {
        return first[key];
      }
    }

    if (elementValue is Map && elementValue.containsKey(key)) {
      return elementValue[key];
    }

    return fallback;
  }

  List _extractLocationsFromHourlyResponse(dynamic data) {
    // 格式 A：預期的 REST records 格式
    final records = data['records'];

    if (records != null && records['Locations'] != null) {
      final locationsNode = records['Locations'];

      if (locationsNode is List && locationsNode.isNotEmpty) {
        return locationsNode[0]['Location'] as List;
      }

      if (locationsNode is Map && locationsNode['Location'] != null) {
        return locationsNode['Location'] as List;
      }
    }

    // 格式 B：cwaopendata 格式
    final cwaOpenData = data['cwaopendata'];

    if (cwaOpenData != null) {
      final dataset = cwaOpenData['Dataset'];

      if (dataset != null && dataset['Locations'] != null) {
        final locationsNode = dataset['Locations'];

        if (locationsNode is Map && locationsNode['Location'] != null) {
          return locationsNode['Location'] as List;
        }

        if (locationsNode is List && locationsNode.isNotEmpty) {
          return locationsNode[0]['Location'] as List;
        }
      }
    }

    throw Exception('逐小時預報資料結構錯誤：找不到 Locations');
  }

  Map<String, dynamic> _pickDefaultTownshipLocation({
    required List locations,
    required String city,
  }) {
    final preferredTownshipMap = {
      '宜蘭縣': '宜蘭市',
      '臺北市': '松山區',
      '新北市': '板橋區',
      '花蓮縣': '花蓮市',
      '桃園市': '桃園區',
      '新竹縣': '竹北市',
      '苗栗縣': '苗栗市',
      '彰化縣': '彰化市',
      '南投縣': '南投市',
      '雲林縣': '斗六市',
      '嘉義縣': '太保市',
      '屏東縣': '屏東市',
      '臺東縣': '臺東市',
      '澎湖縣': '馬公市',
      '基隆市': '中正區',
      '新竹市': '東區',
      '嘉義市': '東區',
      '連江縣': '南竿鄉',
      '高雄市': '鹽埕區',
      '臺中市': '中區',
      '臺南市': '新營區',
      '金門縣': '金城鎮',
    };

    final preferredTownship = preferredTownshipMap[city];

    if (preferredTownship != null) {
      final matched = locations.where(
            (location) => location['LocationName'] == preferredTownship,
      );

      if (matched.isNotEmpty) {
        return Map<String, dynamic>.from(matched.first);
      }
    }

    return Map<String, dynamic>.from(locations.first);
  }

  DateTime _nowInTaiwan() {
    final taiwanNow = DateTime.now().toUtc().add(
      const Duration(hours: 8),
    );

    return DateTime(
      taiwanNow.year,
      taiwanNow.month,
      taiwanNow.day,
      taiwanNow.hour,
      taiwanNow.minute,
      taiwanNow.second,
    );
  }

  DateTime _nextHour(DateTime now) {
    if (now.minute == 0 && now.second == 0) {
      return DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
      );
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(const Duration(hours: 1));
  }

  DateTime _parseTaiwanTime(String value) {
    if (value.trim().isEmpty || value == 'null') {
      throw FormatException('Invalid Taiwan time value: $value');
    }

    final cleaned = value.replaceFirst(
      RegExp(r'([+-]\d{2}:\d{2}|Z)$'),
      '',
    );

    return DateTime.parse(cleaned);
  }

  bool _isSameHour(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }

  String _findWeatherTextByTime({
    required List weatherTimes,
    required DateTime targetTime,
  }) {
    for (final item in weatherTimes) {
      final dataTimeRaw = item['DataTime'];

      if (dataTimeRaw != null) {
        final time = _parseTaiwanTime(dataTimeRaw.toString());

        if (_isSameHour(time, targetTime)) {
          return _readElementValue(
            item,
            'Weather',
            fallback: '晴時多雲',
          ).toString();
        }
      }

      final startRaw = item['StartTime'];
      final endRaw = item['EndTime'];

      if (startRaw != null && endRaw != null) {
        final start = _parseTaiwanTime(startRaw.toString());
        final end = _parseTaiwanTime(endRaw.toString());

        final inRange =
            !targetTime.isBefore(start) && targetTime.isBefore(end);

        if (inRange) {
          return _readElementValue(
            item,
            'Weather',
            fallback: '晴時多雲',
          ).toString();
        }
      }
    }

    return '晴時多雲';
  }

  List<HourlyData> _buildHourlyFallbackFromWeeklyData({
    required List elements,
    required String fallbackTemp,
    required String fallbackDescription,
  }) {
    final List<HourlyData> hourly = [];

    try {
      final tList = elements.firstWhere(
            (e) => e['ElementName'] == '平均溫度',
      )['Time'] as List;

      for (int i = 0; i < 6 && i < tList.length; i++) {
        final hourTemp =
            tList[i]['ElementValue'][0]['Temperature'] ?? fallbackTemp;

        hourly.add(
          HourlyData(
            time: DateTime.parse(tList[i]['StartTime']),
            temperature: double.tryParse(hourTemp.toString()) ?? 0,
            weather: fallbackDescription,
          ),
        );
      }
    } catch (e) {
      hourly.add(
        HourlyData(
          time: DateTime.now(),
          temperature: double.tryParse(fallbackTemp) ?? 0,
          weather: fallbackDescription,
        ),
      );
    }

    return hourly;
  }
}