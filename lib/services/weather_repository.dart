import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';
import 'weather_service.dart';

class WeatherRepository {
  static const String _kCityListKey = 'saved_cities';
  static const String _kCachePrefix = 'weather_cache_';
  static const int _kCacheTtlMinutes = 30; // 30分钟本地强缓存

  /// 获取保存的城市列表（默认包含太原）
  static Future<List<CityItem>> getSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kCityListKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = json.decode(jsonStr) as List;
        return list.map((item) => CityItem.fromJson(item)).toList();
      } catch (_) {}
    }
    // 默认初始城市：太原
    final defaultCities = [
      CityItem(
        name: '太原',
        latitude: 37.86944,
        longitude: 112.56028,
        adminArea: '山西 太原市',
      ),
    ];
    await saveCities(defaultCities);
    return defaultCities;
  }

  /// 保存城市列表
  static Future<void> saveCities(List<CityItem> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(cities.map((c) => c.toJson()).toList());
    await prefs.setString(_kCityListKey, jsonStr);
  }

  /// 获取指定城市天气（先查30分钟内缓存，无缓存或过期则请求网络）
  static Future<WeatherData> getWeather(CityItem city, {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_kCachePrefix${city.latitude}_${city.longitude}';

    if (!forceRefresh) {
      final cachedStr = prefs.getString(cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        try {
          final data = WeatherData.fromJson(json.decode(cachedStr));
          final age = DateTime.now().difference(data.updateTime);
          if (age.inMinutes < _kCacheTtlMinutes) {
            return data;
          }
        } catch (_) {}
      }
    }

    // 缓存过期或强制刷新：请求网络
    final freshData = await WeatherService.fetchWeather(city);
    // 写入本地持久化缓存
    await prefs.setString(cacheKey, json.encode(freshData.toJson()));
    return freshData;
  }
}
