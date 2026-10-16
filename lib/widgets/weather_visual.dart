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

  /// 根据天气 Code 及是否白天，返回动态背景渐变色
  static LinearGradient getGradient(int code, bool isDay) {
    if (!isDay) {
      // 夜间模式：深邃暗夜渐变
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF0A0E1A), Color(0xFF030712)],
      );
    }

    if (code == 0 || code == 1) {
      // 晴朗白天：温暖晨光微蓝渐变
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF0F172A)],
      );
    } else if (code >= 51 && code <= 67) {
      // 雨天：沉静质感深青灰蓝
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF0F172A)],
      );
    } else if (code >= 71 && code <= 86) {
      // 雪天：冷色调冰蓝
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E293B), Color(0xFF475569), Color(0xFF1E293B)],
      );
    } else if (code >= 95) {
      // 雷暴天：深紫夜色
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2E1065), Color(0xFF1E1B4B), Color(0xFF0F172A)],
      );
    }

    // 默认多云/阴天
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1D3557), Color(0xFF1E293B), Color(0xFF0F172A)],
    );
  }
}
