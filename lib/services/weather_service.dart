import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import 'weather_helper.dart';

class WeatherService {
  static const Duration timeoutDuration = Duration(seconds: 4);

  /// 搜索城市列表（支持中文地名，如 "太原"、"北京"）
  static Future<List<CityItem>> searchCities(String query) async {
    final encoded = Uri.encodeComponent(query.trim());
    final isAscii = query.trim().runes.every((r) => r < 128);
    final langParam = isAscii ? '' : '&language=zh';
    final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$encoded&count=10$langParam&format=json');

    try {
      final res = await http.get(url).timeout(timeoutDuration);
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        if (data['results'] != null) {
          return (data['results'] as List).map((item) {
            String admin = '';
            if (item['admin1'] != null) admin += item['admin1'];
            if (item['admin2'] != null && item['admin2'] != item['admin1']) {
              admin += ' ${item['admin2']}';
            }
            if (item['country'] != null && admin.isEmpty) {
              admin = item['country'];
            }
            return CityItem(
              name: item['name'] ?? query,
              latitude: (item['latitude'] as num).toDouble(),
              longitude: (item['longitude'] as num).toDouble(),
              adminArea: admin.trim(),
            );
          }).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// 获取天气数据（主源 Open-Meteo -> 备用源 wttr.in 自动故障转移）
  static Future<WeatherData> fetchWeather(CityItem city) async {
    try {
      return await _fetchFromOpenMeteo(city);
    } catch (e) {
      // 主源异常或超时，自动切换备用源 wttr.in
      return await _fetchFromWttrIn(city);
    }
  }

  /// 主数据源：Open-Meteo（高精度全球气象网）
  static Future<WeatherData> _fetchFromOpenMeteo(CityItem city) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=${city.latitude}&longitude=${city.longitude}'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m'
      '&hourly=temperature_2m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=Asia%2FShanghai',
    );

    final res = await http.get(url).timeout(timeoutDuration);
    if (res.statusCode != 200) {
      throw Exception('Open-Meteo HTTP ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final current = data['current'];
    final daily = data['daily'];
    final hourly = data['hourly'];

    final wCode = (current['weather_code'] as num).toInt();
    final tempMax = (daily['temperature_2m_max'][0] as num).toDouble();
    final tempMin = (daily['temperature_2m_min'][0] as num).toDouble();

    // 解析未来 24 小时
    final List<HourlyForecast> hourlyList = [];
    final List times = hourly['time'] ?? [];
    final List temps = hourly['temperature_2m'] ?? [];
    final List codes = hourly['weather_code'] ?? [];

    final nowHourStr = DateFormat('yyyy-MM-ddTHH:00').format(DateTime.now());
    int startIndex = times.indexWhere((t) => (t as String).startsWith(nowHourStr));
    if (startIndex < 0) startIndex = 0;

    for (int i = startIndex; i < times.length && hourlyList.length < 24; i++) {
      final tStr = times[i] as String;
      final parsed = DateTime.tryParse(tStr) ?? DateTime.now();
      final displayTime = DateFormat('HH:00').format(parsed);
      final c = (codes[i] as num).toInt();
      hourlyList.add(HourlyForecast(
        time: displayTime,
        temperature: (temps[i] as num).toDouble(),
        weatherCode: c,
        weatherText: WeatherHelper.getWeatherDescription(c),
      ));
    }

    // 解析未来 7 天
    final List<DailyForecast> dailyList = [];
    final List dTimes = daily['time'] ?? [];
    final List dMax = daily['temperature_2m_max'] ?? [];
    final List dMin = daily['temperature_2m_min'] ?? [];
    final List dCodes = daily['weather_code'] ?? [];

    for (int i = 0; i < dTimes.length && dailyList.length < 7; i++) {
      final dateObj = DateTime.tryParse(dTimes[i]) ?? DateTime.now();
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final dayName = i == 0
          ? '今天'
          : i == 1
              ? '明天'
              : weekdays[dateObj.weekday - 1];
      final monthDay = '${dateObj.month.toString().padLeft(2, '0')}/${dateObj.day.toString().padLeft(2, '0')}';
      final c = (dCodes[i] as num).toInt();

      dailyList.add(DailyForecast(
        date: '$dayName $monthDay',
        weekday: dateObj.weekday,
        monthDay: monthDay,
        tempMax: (dMax[i] as num).toDouble(),
        tempMin: (dMin[i] as num).toDouble(),
        weatherCode: c,
        weatherText: WeatherHelper.getWeatherDescription(c),
      ));
    }

    return WeatherData(
      cityName: city.name,
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      relativeHumidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherText: WeatherHelper.getWeatherDescription(wCode),
      weatherCode: wCode,
      isDay: (current['is_day'] as num).toInt() == 1,
      tempMax: tempMax,
      tempMin: tempMin,
      hourly: hourlyList,
      daily: dailyList,
      updateTime: DateTime.now(),
      source: 'Open-Meteo',
    );
  }

  /// 备用数据源：wttr.in 开放接口
  static Future<WeatherData> _fetchFromWttrIn(CityItem city) async {
    final url = Uri.parse(
        'https://wttr.in/${city.latitude},${city.longitude}?format=j1&lang=zh');

    final res = await http.get(url).timeout(timeoutDuration);
    if (res.statusCode != 200) {
      throw Exception('wttr.in HTTP ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final current = data['current_condition'][0];
    final weatherDays = data['weather'] as List;

    final desc = current['lang_zh'] != null && current['lang_zh'].isNotEmpty
        ? current['lang_zh'][0]['value']
        : current['weatherDesc'][0]['value'];
    final wCode = WeatherHelper.wttrDescToCode(desc);

    final todayMax = double.tryParse(weatherDays[0]['maxtempC']) ?? 20.0;
    final todayMin = double.tryParse(weatherDays[0]['mintempC']) ?? 10.0;

    // 解析逐小时
    final List<HourlyForecast> hourlyList = [];
    if (weatherDays.isNotEmpty) {
      final hourlyData = weatherDays[0]['hourly'] as List;
      for (var h in hourlyData) {
        final timeInt = int.tryParse(h['time']) ?? 0;
        final hour = timeInt ~/ 100;
        final hDesc = h['lang_zh'] != null && h['lang_zh'].isNotEmpty
            ? h['lang_zh'][0]['value']
            : h['weatherDesc'][0]['value'];
        final c = WeatherHelper.wttrDescToCode(hDesc);
        hourlyList.add(HourlyForecast(
          time: '${hour.toString().padLeft(2, '0')}:00',
          temperature: double.tryParse(h['tempC']) ?? 15.0,
          weatherCode: c,
          weatherText: WeatherHelper.getWeatherDescription(c),
        ));
      }
    }

    // 解析每日
    final List<DailyForecast> dailyList = [];
    for (int i = 0; i < weatherDays.length; i++) {
      final item = weatherDays[i];
      final dateObj = DateTime.tryParse(item['date']) ?? DateTime.now();
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final dayName = i == 0
          ? '今天'
          : i == 1
              ? '明天'
              : weekdays[dateObj.weekday - 1];
      final monthDay = '${dateObj.month.toString().padLeft(2, '0')}/${dateObj.day.toString().padLeft(2, '0')}';
      final dDesc = item['hourly'][4]['weatherDesc'][0]['value'];
      final c = WeatherHelper.wttrDescToCode(dDesc);

      dailyList.add(DailyForecast(
        date: '$dayName $monthDay',
        weekday: dateObj.weekday,
        monthDay: monthDay,
        tempMax: double.tryParse(item['maxtempC']) ?? 20.0,
        tempMin: double.tryParse(item['mintempC']) ?? 10.0,
        weatherCode: c,
        weatherText: WeatherHelper.getWeatherDescription(c),
      ));
    }

    return WeatherData(
      cityName: city.name,
      temperature: double.tryParse(current['temp_C']) ?? 15.0,
      apparentTemperature: double.tryParse(current['FeelsLikeC']) ?? 15.0,
      relativeHumidity: int.tryParse(current['humidity']) ?? 50,
      windSpeed: double.tryParse(current['windspeedKmph']) ?? 10.0,
      weatherText: WeatherHelper.getWeatherDescription(wCode),
      weatherCode: wCode,
      isDay: true,
      tempMax: todayMax,
      tempMin: todayMin,
      hourly: hourlyList,
      daily: dailyList,
      updateTime: DateTime.now(),
      source: 'wttr.in (备用源)',
    );
  }
}
