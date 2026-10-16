import 'package:flutter/material.dart';

class WeatherVisual {
  /// 根据 WMO Code 返回对应天气 Emoji
  static String getIconEmoji(int code) {
    if (code == 0) return '☀️';
    if (code == 1) return '🌤️';
    if (code == 2) return '⛅';
    if (code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 57) return '🌦️';
    if (code >= 61 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌧️';
    if (code >= 85 && code <= 86) return '🌨️';
    if (code >= 95) return '⛈️';
    return '⛅';
  }

  /// 通透清爽明亮色系渐变：彻底告别死黑色！
  /// 采用冰川蓝、晨曦浅天蓝与莫兰迪柔和灰蓝质感
  static LinearGradient getGradient(int code, bool isDay) {
    if (code == 0 || code == 1) {
      // 晴天：通透晨空冰川微蓝渐变
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF60A5FA), Color(0xFFBAE6FD)],
      );
    } else if (code >= 51 && code <= 67) {
      // 雨天：清润水雾灰蓝（绝非黑色）
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFFCBD5E1)],
      );
    } else if (code >= 71 && code <= 86) {
      // 雪天：极光纯净浅冰白蓝
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF60A5FA), Color(0xFF93C5FD), Color(0xFFE0F2FE)],
      );
    }

    // 默认多云/阴天：高雅莫兰迪冰川灰蓝渐变
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF93C5FD)],
    );
  }
}
