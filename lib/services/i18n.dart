class I18n {
  static String lang = 'zh'; // 'zh' or 'en'

  static bool get isEn => lang == 'en';

  static String get appName => isEn ? 'FineWeather' : '初晴天气';
  static String get searchCityHint => isEn ? 'Search city (e.g. New York, Beijing, London)' : '搜索城市（如：太原、北京、纽约）';
  static String get searchGuide => isEn ? 'Type English or Chinese city name to search' : '输入城市中文名称、拼音或英文搜索';
  static String get noCityFound => isEn ? 'No matching city found' : '未找到匹配的城市，请检查名称';
  static String get cityManager => isEn ? 'City Management' : '城市管理';
  static String get currentLoc => isEn ? 'Location' : '当前定位';
  static String get defaultCityName => isEn ? 'Current Location' : '当前位置';
  static String get defaultAdminArea => isEn ? 'Located City' : '定位城市';
  static String get keepOneCity => isEn ? 'Keep at least one city' : '至少保留一个常用城市';
  static String get locating => isEn ? 'Locating...' : '定位中...';
  static String get locateFailed => isEn ? 'Location failed, using default' : '定位失败，已切换至默认城市';
  static String get settings => isEn ? 'Settings' : '设置';
  static String get language => isEn ? 'Language / 语言' : '界面语言';
  static String get langZh => '简体中文';
  static String get langEn => 'English';
  static String get about => isEn ? 'About' : '关于初晴天气';
  static String get pureMode => isEn ? '🛡️ Pure Mode · Zero Ads · Zero Tracking' : '🛡️ Pure 纯净模式 · 零广告 · 零资讯跟踪';
  static String get dataSource => isEn ? 'Data Source: Open-Meteo & wttr.in (Dual Redundancy)' : '数据源: Open-Meteo & wttr.in 双源冗余保障';
  static String get hourlyForecast => isEn ? 'Hourly Forecast · 24 Hours' : '逐小时预报 · 24小时';
  static String get dailyForecast => isEn ? '7-Day Forecast' : '7 天天气预报';
  static String get feelsLike => isEn ? 'Feels Like' : '体感';
  static String get humidity => isEn ? 'Relative Humidity' : '相对湿度';
  static String get wind => isEn ? 'Wind Speed' : '风向风速';
  static String get uvIndex => isEn ? 'UV Index' : '紫外线指数';
  static String get visibility => isEn ? 'Visibility' : '能见度';
  static String get airQuality => isEn ? 'Air Excellent' : '空气 优';
  static String get high => isEn ? 'H' : '最高';
  static String get low => isEn ? 'L' : '最低';
  static String get now => isEn ? 'Now' : '现在';
  static String get retry => isEn ? 'Retry' : '点击重试';
  static String get close => isEn ? 'Close' : '关闭';
  static String get comfortable => isEn ? 'Comfortable' : '体感舒适';
  static String get gentleBreeze => isEn ? 'Gentle Breeze' : '微风拂面';
  static String get uvLow => isEn ? 'No Protection Needed' : '无需特别防护';
  static String get clearView => isEn ? 'Clear View' : '视线开阔清晰';
  static String getLocalizedCityName(String name) {
    if (isEn) {
      if (name.contains('太原')) return 'Taiyuan';
      if (name.contains('北京')) return 'Beijing';
      if (name.contains('上海')) return 'Shanghai';
      if (name.contains('广州')) return 'Guangzhou';
      if (name.contains('深圳')) return 'Shenzhen';
      if (name.contains('纽约')) return 'New York';
      if (name.contains('伦敦')) return 'London';
    } else {
      final lower = name.toLowerCase();
      if (lower == 'taiyuan') return '太原';
      if (lower == 'beijing') return '北京';
      if (lower == 'shanghai') return '上海';
      if (lower == 'guangzhou') return '广州';
      if (lower == 'shenzhen') return '深圳';
      if (lower == 'new york') return '纽约';
      if (lower == 'london') return '伦敦';
    }
    return name;
  }

  static String getLocalizedAdminArea(String admin) {
    var a = admin.trim();
    // 彻底清洗英文拼音尾巴（如 Shanxi Sheng -> 山西省 / Shanxi）
    a = a.replaceAll(' Sheng', '省').replaceAll(' sheng', '省');
    a = a.replaceAll(' Shi', '市').replaceAll(' shi', '市');
    a = a.replaceAll(' Qu', '区').replaceAll(' qu', '区');

    if (isEn) {
      a = a.replaceAll('山西省', 'Shanxi').replaceAll('山西', 'Shanxi');
      a = a.replaceAll('太原市', 'Taiyuan').replaceAll('太原', 'Taiyuan');
      a = a.replaceAll('北京市', 'Beijing').replaceAll('北京', 'Beijing');
      a = a.replaceAll('上海市', 'Shanghai').replaceAll('上海', 'Shanghai');
      a = a.replaceAll('广州市', 'Guangzhou').replaceAll('广州', 'Guangzhou');
      a = a.replaceAll('深圳市', 'Shenzhen').replaceAll('深圳', 'Shenzhen');
      a = a.replaceAll('当前定位', 'Location').replaceAll('定位城市', 'Location');
      a = a.replaceAll('省', '').replaceAll('市', '').replaceAll('区', '').trim();
      // 如果同时有 Shanxi 和 Taiyuan，简化为纯粹的 Shanxi
      if (a.contains('Shanxi') && a.contains('Taiyuan')) {
        a = 'Shanxi';
      }
      return a;
    } else {
      a = a.replaceAll('Shanxi', '山西');
      a = a.replaceAll('Taiyuan', '太原');
      a = a.replaceAll('Beijing', '北京');
      a = a.replaceAll('Location', '当前定位').replaceAll('Located', '当前定位');
      if (a.contains('山西') && !a.contains('山西省')) {
        a = a.replaceAll('山西', '山西省');
      }
      return a;
    }
  }

  static String get aboutDesc => isEn
      ? 'FineWeather is an open-source, ultra-clean weather application created by sbitoh. Dedicated to restoring the purest weather experience: zero advertisements, zero newsfeeds, zero tracking, driven by dual zero-registration global meteorological data.'
      : '初晴天气（FineWeather）是由 sbitoh 独立设计与开发的开源纯净天气应用。\n\n致力于扫除传统天气软件满屏广告与低俗信息流的阴霾，还原最纯粹、优雅的气象体验：\n\n• 🛡️ 零广告、零开屏、零新闻资讯流\n• 🌐 双免注册全球气象源（Open-Meteo + wttr.in）静默容灾\n• ❄️ 清透冰川蓝与深色光影自适应\n• 📱 原生桌面天气微组件支持\n• 📍 本地化定位，隐私数据绝不上报云端';
}
