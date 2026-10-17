import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import 'i18n.dart';

class LocationService {
  /// 获取当前经纬度及高精度逆地理编码城市名
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
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      final lat = pos.latitude;
      final lon = pos.longitude;
      final isEn = I18n.isEn;

      String cityName = isEn ? 'Taiyuan' : '太原';
      String admin = isEn ? 'Shanxi' : '山西省';

      // 4. 第一通道：OpenStreetMap Nominatim 高精度逆地理反查真实城市
      try {
        final langCode = isEn ? 'en' : 'zh-CN';
        final osmUrl = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=$langCode');
        final res = await http.get(osmUrl, headers: {
          'User-Agent': 'FineWeather/0.2.1'
        }).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = json.decode(utf8.decode(res.bodyBytes));
          final addr = data['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final rawCity = addr['city'] ??
                addr['county'] ??
                addr['town'] ??
                addr['district'] ??
                '';
            final rawAdmin = addr['state'] ?? addr['province'] ?? '';
            if (rawCity.toString().isNotEmpty) {
              cityName = _cleanCityName(rawCity.toString(), isEn);
              admin = rawAdmin.toString();
            }
          }
        }
      } catch (_) {}

      // 5. 第二通道备用：BigDataCloud 逆地理
      if (cityName == '太原' || cityName == 'Taiyuan') {
        try {
          final langParam = isEn ? 'en' : 'zh';
          final bdcUrl = Uri.parse(
              'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=$langParam');
          final res = await http.get(bdcUrl).timeout(const Duration(seconds: 3));
          if (res.statusCode == 200) {
            final data = json.decode(utf8.decode(res.bodyBytes));
            final rawCity = data['city'] ?? data['locality'] ?? '';
            final rawAdmin = data['principalSubdivision'] ?? '';
            if (rawCity.toString().isNotEmpty) {
              cityName = _cleanCityName(rawCity.toString(), isEn);
              admin = rawAdmin.toString();
            }
          }
        } catch (_) {}
      }

      final locTag = isEn ? 'Location' : '当前定位';
      final finalAdminArea = admin.isNotEmpty ? '$admin · $locTag' : locTag;

      return CityItem(
        name: cityName,
        latitude: lat,
        longitude: lon,
        adminArea: finalAdminArea,
      );
    } catch (_) {
      return null;
    }
  }

  static String _cleanCityName(String raw, bool isEn) {
    var c = raw.trim();
    if (isEn) {
      c = c.replaceAll(' City', '').replaceAll(' city', '').trim();
    } else {
      // 中文去掉多余的“市”、“区”后缀，保持简洁
      if (c.endsWith('市') && c.length > 2) {
        c = c.substring(0, c.length - 1);
      }
      // 常见拼音反向纠偏为中文
      final lower = c.toLowerCase();
      if (lower == 'taiyuan') c = '太原';
      if (lower == 'beijing') c = '北京';
      if (lower == 'shanghai') c = '上海';
      if (lower == 'guangzhou') c = '广州';
      if (lower == 'shenzhen') c = '深圳';
      if (lower == 'new york') c = '纽约';
      if (lower == 'london') c = '伦敦';
    }
    return c;
  }
}
