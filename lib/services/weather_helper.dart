class WeatherHelper {
  /// WMO 天气代码转换为多语言描述
  static String getWeatherDescription(int code, {bool isEn = false}) {
    if (isEn) {
      switch (code) {
        case 0:
          return 'Clear Sky';
        case 1:
          return 'Mainly Clear';
        case 2:
          return 'Partly Cloudy';
        case 3:
          return 'Overcast';
        case 45:
          return 'Fog';
        case 48:
          return 'Depositing Rime Fog';
        case 51:
          return 'Light Drizzle';
        case 53:
          return 'Moderate Drizzle';
        case 55:
          return 'Dense Drizzle';
        case 56:
        case 57:
          return 'Freezing Drizzle';
        case 61:
          return 'Slight Rain';
        case 63:
          return 'Moderate Rain';
        case 65:
          return 'Heavy Rain';
        case 66:
        case 67:
          return 'Freezing Rain';
        case 71:
          return 'Slight Snow';
        case 73:
          return 'Moderate Snow';
        case 75:
          return 'Heavy Snow';
        case 77:
          return 'Snow Grains';
        case 80:
          return 'Rain';
        case 81:
          return 'Showers';
        case 82:
          return 'Violent';
        case 85:
          return 'Slight Snow Showers';
        case 86:
          return 'Heavy Snow Showers';
        case 95:
          return 'Thunderstorm';
        case 96:
        case 99:
          return 'Thunderstorm with Hail';
        default:
          return 'Partly Cloudy';
      }
    }

    switch (code) {
      case 0:
        return '晴朗';
      case 1:
        return '大部晴朗';
      case 2:
        return '多云';
      case 3:
        return '阴天';
      case 45:
        return '有雾';
      case 48:
        return '浓雾/白霜';
      case 51:
        return '轻微毛毛雨';
      case 53:
        return '毛毛雨';
      case 55:
        return '强毛毛雨';
      case 56:
      case 57:
        return '冻毛毛雨';
      case 61:
        return '小雨';
      case 63:
        return '中雨';
      case 65:
        return '大雨/暴雨';
      case 66:
      case 67:
        return '冻雨';
      case 71:
        return '小雪';
      case 73:
        return '中雪';
      case 75:
        return '大雪/暴雪';
      case 77:
        return '雪粒';
      case 80:
        return '微弱阵雨';
      case 81:
        return '中度阵雨';
      case 82:
        return '强阵雨';
      case 85:
        return '小阵雪';
      case 86:
        return '大阵雪';
      case 95:
        return '雷阵雨';
      case 96:
      case 99:
        return '雷暴伴冰雹';
      default:
        return '多云';
    }
  }

  /// 转换 wttr.in 的天气描述到 WMO code
  static int wttrDescToCode(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('sunny') || d.contains('clear')) return 0;
    if (d.contains('partly cloudy')) return 2;
    if (d.contains('cloudy') || d.contains('overcast')) return 3;
    if (d.contains('fog') || d.contains('mist')) return 45;
    if (d.contains('thunder') || d.contains('storm')) return 95;
    if (d.contains('snow') || d.contains('blizzard')) return 73;
    if (d.contains('heavy rain')) return 65;
    if (d.contains('light rain') || d.contains('drizzle') || d.contains('patchy rain')) return 61;
    if (d.contains('rain') || d.contains('shower')) return 63;
    return 2;
  }
}
