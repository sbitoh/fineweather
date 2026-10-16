import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class LocationService {
  /// 获取当前经纬度及逆地理编码城市名
  static Future<CityItem?> getCurrentCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 检查位置服务是否开启
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // 2. 检查并申请权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3. 获取当前 GPS 位置
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 4),
      );

      // 4. 反向通过 Open-Meteo 逆地理查找城市名
      final reverseUrl = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=${pos.latitude.toStringAsFixed(2)},${pos.longitude.toStringAsFixed(2)}&count=1&language=zh&format=json');

      String cityName = '当前位置';
      String admin = '';
      try {
        final res = await http.get(reverseUrl).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = json.decode(utf8.decode(res.bodyBytes));
          if (data['results'] != null && (data['results'] as List).isNotEmpty) {
            final first = data['results'][0];
            cityName = first['name'] ?? cityName;
            admin = first['admin1'] ?? '';
          }
        }
      } catch (_) {}

      return CityItem(
        name: cityName,
        latitude: pos.latitude,
        longitude: pos.longitude,
        adminArea: admin.isNotEmpty ? admin : '定位城市',
      );
    } catch (_) {
      return null;
    }
  }
}
