import 'package:flutter_test/flutter_test.dart';
import 'package:fineweather/services/i18n.dart';
import 'package:fineweather/services/weather_helper.dart';

void main() {
  group('中英文本地化完整性严密自测', () {
    test('1. 中文模式地址与归属地自测', () {
      I18n.lang = 'zh';
      expect(I18n.isEn, false);

      // 验证城市名绝无英文
      expect(I18n.getLocalizedCityName('Taiyuan'), '太原');
      expect(I18n.getLocalizedCityName('taiyuan'), '太原');
      expect(I18n.getLocalizedCityName('太原'), '太原');

      // 验证归属地绝无 Sheng / sheng / 英文残留
      expect(I18n.getLocalizedAdminArea('Shanxi Sheng · Location'), contains('山西省'));
      expect(I18n.getLocalizedAdminArea('Shanxi Sheng · Location'), isNot(contains('Sheng')));
      expect(I18n.getLocalizedAdminArea('Shanxi Sheng · Location'), isNot(contains('Location')));
      expect(I18n.getLocalizedAdminArea('Shanxi · 当前定位'), contains('山西省 · 当前定位'));
    });

    test('2. 英文模式地址与归属地自测', () {
      I18n.lang = 'en';
      expect(I18n.isEn, true);

      // 验证城市名为英文
      expect(I18n.getLocalizedCityName('太原'), 'Taiyuan');
      expect(I18n.getLocalizedCityName('Taiyuan'), 'Taiyuan');

      // 验证归属地为纯英文
      final enAdmin = I18n.getLocalizedAdminArea('山西省 · 当前定位');
      expect(enAdmin, contains('Shanxi'));
      expect(enAdmin, isNot(contains('省')));
      expect(enAdmin, contains('Location'));

      final shengAdmin = I18n.getLocalizedAdminArea('Shanxi Sheng · Location');
      expect(shengAdmin, isNot(contains('Sheng')));
      expect(shengAdmin, contains('Shanxi'));
    });

    test('3. 天气状况多语言严密自测', () {
      // 中文
      I18n.lang = 'zh';
      expect(WeatherHelper.getWeatherDescription(55, isEn: false), '强毛毛雨');
      expect(WeatherHelper.getWeatherDescription(61, isEn: false), '小雨');

      // 英文
      I18n.lang = 'en';
      expect(WeatherHelper.getWeatherDescription(55, isEn: true), 'Dense Drizzle');
      expect(WeatherHelper.getWeatherDescription(61, isEn: true), 'Slight Rain');
    });
  });
}
