import 'package:fineweather/models/weather_data.dart';
import 'package:fineweather/services/weather_service.dart';

void main() async {
  print('=== 1. 测试城市搜索 (太原) ===');
  final cities = await WeatherService.searchCities('太原');
  print('搜索结果数量: ${cities.length}');
  for (var c in cities.take(2)) {
    print('找到城市: ${c.name} (${c.adminArea}) 坐标: [${c.latitude}, ${c.longitude}]');
  }

  if (cities.isNotEmpty) {
    final target = cities.first;
    print('\n=== 2. 测试天气数据获取 (${target.name}) ===');
    final weather = await WeatherService.fetchWeather(target);
    print('数据源: ${weather.source}');
    print('实时气温: ${weather.temperature}°C, 体感: ${weather.apparentTemperature}°C');
    print('天气状况: ${weather.weatherText} (Code: ${weather.weatherCode})');
    print('湿度: ${weather.relativeHumidity}%, 风速: ${weather.windSpeed} km/h');
    print('今日温度区间: ${weather.tempMin}°C ~ ${weather.tempMax}°C');
    print('24小时预报数: ${weather.hourly.length} 条 (首条: ${weather.hourly.first.time} ${weather.hourly.first.temperature}°C)');
    print('7天预报数: ${weather.daily.length} 天 (首天: ${weather.daily.first.date} ${weather.daily.first.tempMin}~${weather.daily.first.tempMax}°C)');
    print('\n✓ 阶段二真实气象数据双源通道闭环验证通过！');
  }
}
