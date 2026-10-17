import 'package:flutter_test/flutter_test.dart';
import 'package:fineweather/services/weather_service.dart';

void main() {
  test('双源并发检索城市测试 - 焦作', () async {
    final results = await WeatherService.searchCities('焦作');
    print('焦作搜索结果数量: ${results.length}');
    for (var r in results) {
      print('  -> 城市: ${r.name}, 区域: ${r.adminArea}, 坐标: [${r.latitude}, ${r.longitude}]');
    }
    expect(results.isNotEmpty, true);
    final jiaozuo = results.firstWhere((r) => r.name.contains('焦作') || r.adminArea.contains('河南') || r.adminArea.contains('China'));
    expect(jiaozuo != null, true);

    print('\n测试为焦作获取天气数据...');
    final weather = await WeatherService.fetchWeather(jiaozuo);
    print('焦作气象源: ${weather.source}');
    print('实时气温: ${weather.temperature}°C, 天气: ${weather.weatherText}');
    expect(weather.temperature != null, true);
  });
}
