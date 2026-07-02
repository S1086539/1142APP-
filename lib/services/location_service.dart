import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const String _defaultCity = '臺北市';

  static const Set<String> _supportedTaiwanCities = {
    '宜蘭縣',
    '桃園市',
    '新竹縣',
    '苗栗縣',
    '彰化縣',
    '南投縣',
    '雲林縣',
    '嘉義縣',
    '屏東縣',
    '臺東縣',
    '花蓮縣',
    '澎湖縣',
    '基隆市',
    '新竹市',
    '嘉義市',
    '臺北市',
    '高雄市',
    '新北市',
    '臺中市',
    '臺南市',
    '連江縣',
    '金門縣',
  };

  Future<String?> getCurrentCity() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition();

      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': pos.latitude,
          'lon': pos.longitude,
          'format': 'json',
          'accept-language': 'zh-TW',
        },
        options: Options(
          headers: {
            'User-Agent': 'MyWeatherApp/1.0',
          },
        ),
      );

      final address = res.data['address'];

      final String? city =
          address?['city']?.toString() ??
              address?['county']?.toString() ??
              address?['state']?.toString();

      return _normalizeTaiwanCity(city);
    } catch (e) {
      print('定位更新失敗: $e');
      return null;
    }
  }

  String _normalizeTaiwanCity(String? city) {
    if (city == null || city.trim().isEmpty) {
      return _defaultCity;
    }

    final normalized = city.trim().replaceAll('台', '臺');

    if (_supportedTaiwanCities.contains(normalized)) {
      return normalized;
    }

    print('定位結果不是支援的臺灣縣市：$normalized，改用 $_defaultCity');
    return _defaultCity;
  }
}