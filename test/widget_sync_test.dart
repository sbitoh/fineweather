import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fineweather/models/weather_data.dart';
import 'package:fineweather/services/weather_repository.dart';
import 'package:fineweather/services/i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('端到端数据与桌面小部件一致性严格测试', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    final mockWeatherData = WeatherData(
      cityName: '太原',
      temperature: 13.0,
      apparentTemperature: 13.0,
      relativeHumidity: 94,
      windSpeed: 5.0,
      weatherText: '强毛毛雨',
      weatherCode: 55,
      isDay: true,
      tempMin: 10.0,
      tempMax: 14.0,
      hourly: [
        HourlyForecast(time: '11:00', temperature: 13.0, weatherCode: 55, weatherText: '强毛毛雨'),
      ],
      daily: [
        DailyForecast(date: '2026-10-17', monthDay: '10/17', weekday: 6, tempMin: 10.0, tempMax: 14.0, weatherCode: 55, weatherText: '强毛毛雨'),
      ],
      updateTime: DateTime.now(),
      source: 'Open-Meteo',
    );

    test('1. 中文模式下：写入与广播数据完全转为中文，绝无英文Taiyuan和Sheng', () async {
      I18n.lang = 'zh';
      await WeatherRepository.syncWidgetData(mockWeatherData, lang: 'zh');

      final prefs = await SharedPreferences.getInstance();
      
      // 验证城市名必须是中文“太原”
      final cityZh = prefs.getString('flutter.widget_city');
      expect(cityZh, '太原');

      // 验证天气描述与高低温必须严格一致
      final temp = prefs.getString('flutter.widget_temp');
      final range = prefs.getString('flutter.widget_range');
      final desc = prefs.getString('flutter.widget_desc');
      final sub = prefs.getString('flutter.widget_sub');
      final date = prefs.getString('flutter.widget_date');

      final nowLabel = prefs.getString('flutter.widget_now');

      expect(temp, '13°');
      expect(range, '10° / 14°');
      expect(desc, '强毛毛雨');
      expect(sub, '强毛毛雨 · 10° / 14°');
      expect(date, contains('10月17日 周六'));
      expect(nowLabel, '现在');

      // 验证 4x1 和 4x2 读取的共享字段 100% 对齐
      expect(sub, contains(desc!));
      expect(sub, contains(range!));
    });

    test('2. 英文模式下：热切换立即转为纯正英文Taiyuan和Dense Drizzle', () async {
      I18n.lang = 'en';
      await WeatherRepository.syncWidgetData(mockWeatherData, lang: 'en');

      final prefs = await SharedPreferences.getInstance();

      final cityEn = prefs.getString('flutter.widget_city');
      expect(cityEn, 'Taiyuan');

      final desc = prefs.getString('flutter.widget_desc');
      final sub = prefs.getString('flutter.widget_sub');
      final date = prefs.getString('flutter.widget_date');
      final nowLabel = prefs.getString('flutter.widget_now');

      expect(desc, 'Dense Drizzle');
      expect(sub, 'Dense Drizzle · 10° / 14°');
      expect(date, contains('Oct 17 Sat'));
      expect(nowLabel, 'Now');
    });
  });
}
