import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';
import 'weather_service.dart';
import 'weather_helper.dart';
import 'i18n.dart';

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

    // 缓存最新请求的天气对象，方便语言热切换时直接读取
    _lastWeatherData = freshData;

    // 同步给 Android 原生桌面小组件
    await _syncWidgetData(freshData);

    return freshData;
  }

  static WeatherData? _lastWeatherData;

  static Future<void> syncWidgetData(WeatherData data, {String? lang}) =>
      _syncWidgetData(data, lang: lang);

  /// 同步数据至桌面插件并触发原生刷新
  static Future<void> _syncWidgetData(WeatherData data, {String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final isEn = (lang ?? I18n.lang) == 'en';
    final desc = WeatherHelper.getWeatherDescription(data.weatherCode, isEn: isEn);
    final cityName = isEn ? _toEnglishCityName(data.cityName) : _toChineseCityName(data.cityName);
    final sub = isEn
        ? '$desc · ${data.tempMin.round()}° / ${data.tempMax.round()}°'
        : '$desc · ${data.tempMin.round()}° / ${data.tempMax.round()}°';

    final now = DateTime.now();
    final enMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final zhDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final dateStr = isEn
        ? '${enMonths[now.month - 1]} ${now.day} ${enDays[now.weekday - 1]}'
        : '${now.month}月${now.day}日 ${zhDays[now.weekday - 1]}';
    final nowLabel = isEn ? 'Now' : '现在';

    for (var key in [
      'flutter.widget_city',
      'flutter.widget_temp',
      'flutter.widget_desc',
      'flutter.widget_sub',
      'flutter.widget_range',
      'flutter.widget_date',
      'widget_city',
      'widget_temp',
      'widget_desc',
      'widget_sub',
      'widget_range',
      'widget_date',
    ]) {
      // 保证两种 key 前缀都写入，双重兼容
    }

    await prefs.setString('widget_city', cityName);
    await prefs.setString('widget_temp', '${data.temperature.round()}°');
    await prefs.setString('widget_desc', desc);
    await prefs.setString('widget_sub', sub);
    await prefs.setString('widget_range', '${data.tempMin.round()}° / ${data.tempMax.round()}°');
    await prefs.setString('widget_date', dateStr);
    await prefs.setString('widget_now', nowLabel);

    // 写入 HomeWidget 专用存储，保证不管插件从哪读都能读到最新数据
    try {
      await HomeWidget.saveWidgetData<String>('widget_city', cityName);
      await HomeWidget.saveWidgetData<String>('widget_temp', '${data.temperature.round()}°');
      await HomeWidget.saveWidgetData<String>('widget_desc', desc);
      await HomeWidget.saveWidgetData<String>('widget_sub', sub);
      await HomeWidget.saveWidgetData<String>('widget_range', '${data.tempMin.round()}° / ${data.tempMax.round()}°');
      await HomeWidget.saveWidgetData<String>('widget_date', dateStr);
      await HomeWidget.saveWidgetData<String>('widget_now', nowLabel);

      await HomeWidget.saveWidgetData<String>('flutter.widget_city', cityName);
      await HomeWidget.saveWidgetData<String>('flutter.widget_temp', '${data.temperature.round()}°');
      await HomeWidget.saveWidgetData<String>('flutter.widget_desc', desc);
      await HomeWidget.saveWidgetData<String>('flutter.widget_sub', sub);
      await HomeWidget.saveWidgetData<String>('flutter.widget_range', '${data.tempMin.round()}° / ${data.tempMax.round()}°');
      await HomeWidget.saveWidgetData<String>('flutter.widget_date', dateStr);
      await HomeWidget.saveWidgetData<String>('flutter.widget_now', nowLabel);
    } catch (_) {}

    // 触发 Android 原生 AppWidget 刷新
    try {
      await HomeWidget.updateWidget(
        name: 'WeatherWidget4x1Provider',
        androidName: 'WeatherWidget4x1Provider',
        qualifiedAndroidName: 'com.sbitoh.fineweather.WeatherWidget4x1Provider',
      );
      await HomeWidget.updateWidget(
        name: 'WeatherWidget4x2Provider',
        androidName: 'WeatherWidget4x2Provider',
        qualifiedAndroidName: 'com.sbitoh.fineweather.WeatherWidget4x2Provider',
      );
      await HomeWidget.updateWidget(
        name: 'WeatherWidget4x2CleanProvider',
        androidName: 'WeatherWidget4x2CleanProvider',
        qualifiedAndroidName: 'com.sbitoh.fineweather.WeatherWidget4x2CleanProvider',
      );
    } catch (_) {}
  }

  /// 当语言热切换时，直接根据当前缓存同步小部件
  static Future<void> updateWidgetData({String? lang}) async {
    if (_lastWeatherData != null) {
      await _syncWidgetData(_lastWeatherData!, lang: lang);
      return;
    }
    final cities = await getSavedCities();
    if (cities.isEmpty) return;
    final current = cities.first;
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_kCachePrefix${current.latitude}_${current.longitude}';
    final cachedStr = prefs.getString(cacheKey);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        final data = WeatherData.fromJson(json.decode(cachedStr));
        await _syncWidgetData(data, lang: lang);
      } catch (_) {}
    }
  }

  static String _toChineseCityName(String name) {
    final lower = name.toLowerCase();
    if (lower == 'taiyuan') return '太原';
    if (lower == 'beijing') return '北京';
    if (lower == 'shanghai') return '上海';
    if (lower == 'guangzhou') return '广州';
    if (lower == 'shenzhen') return '深圳';
    if (lower == 'new york') return '纽约';
    if (lower == 'london') return '伦敦';
    return name;
  }

  static String toEnglishCityName(String cnName) => _toEnglishCityName(cnName);

  static String _toEnglishCityName(String cnName) {
    if (cnName.contains('太原')) return 'Taiyuan';
    if (cnName.contains('北京')) return 'Beijing';
    if (cnName.contains('上海')) return 'Shanghai';
    if (cnName.contains('广州')) return 'Guangzhou';
    if (cnName.contains('深圳')) return 'Shenzhen';
    if (cnName.contains('纽约')) return 'New York';
    if (cnName.contains('伦敦')) return 'London';
    return cnName;
  }
}
