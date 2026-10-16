class I18n {
  static String lang = 'zh'; // 'zh' or 'en'

  static bool get isEn => lang == 'en';

  static String get appName => isEn ? 'FineWeather' : '初晴天气';
  static String get searchCityHint => isEn ? 'Search city (e.g. Taiyuan, Beijing, London)' : '搜索城市（如：太原、北京、上海）';
  static String get searchGuide => isEn ? 'Type city name or pinyin to search' : '输入城市中文名称或拼音进行搜索';
  static String get noCityFound => isEn ? 'No matching city found' : '未找到匹配的城市，请检查名称';
  static String get cityManager => isEn ? 'City Management' : '城市管理';
  static String get currentLoc => isEn ? 'Current Location' : '当前定位';
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

  static String get aboutDesc => isEn
      ? 'FineWeather is an open-source, ultra-clean weather application created by Junye (sbitoh). Dedicated to restoring the purest weather experience: zero advertisements, zero newsfeeds, zero tracking, driven by dual zero-registration global meteorological data.'
      : '初晴天气（FineWeather）是由 Junye (sbitoh) 独立设计与开发的开源纯净天气应用。\n\n致力于扫除传统天气软件满屏广告与低俗信息流的阴霾，还原最纯粹、优雅的气象体验：\n\n• 🛡️ 零广告、零开屏、零新闻资讯流\n• 🌐 双免注册全球气象源（Open-Meteo + wttr.in）静默容灾\n• ❄️ 清透冰川蓝与深色光影自适应\n• 📱 原生桌面天气微组件支持\n• 📍 本地化定位，隐私数据绝不上报云端';
}
