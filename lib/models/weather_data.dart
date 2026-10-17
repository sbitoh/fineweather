class WeatherData {
  final String cityName;
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final String weatherText;
  final int weatherCode;
  final bool isDay;
  final double tempMax;
  final double tempMin;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime updateTime;
  final String source; // 'open-meteo' or 'wttr.in'

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.weatherText,
    required this.weatherCode,
    required this.isDay,
    required this.tempMax,
    required this.tempMin,
    required this.hourly,
    required this.daily,
    required this.updateTime,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'temperature': temperature,
        'apparentTemperature': apparentTemperature,
        'relativeHumidity': relativeHumidity,
        'windSpeed': windSpeed,
        'weatherText': weatherText,
        'weatherCode': weatherCode,
        'isDay': isDay,
        'tempMax': tempMax,
        'tempMin': tempMin,
        'hourly': hourly.map((h) => h.toJson()).toList(),
        'daily': daily.map((d) => d.toJson()).toList(),
        'updateTime': updateTime.toIso8601String(),
        'source': source,
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        cityName: json['cityName'] ?? '',
        temperature: (json['temperature'] as num).toDouble(),
        apparentTemperature: (json['apparentTemperature'] as num).toDouble(),
        relativeHumidity: (json['relativeHumidity'] as num).toInt(),
        windSpeed: (json['windSpeed'] as num).toDouble(),
        weatherText: json['weatherText'] ?? '',
        weatherCode: (json['weatherCode'] as num).toInt(),
        isDay: json['isDay'] ?? true,
        tempMax: (json['tempMax'] as num).toDouble(),
        tempMin: (json['tempMin'] as num).toDouble(),
        hourly: (json['hourly'] as List)
            .map((h) => HourlyForecast.fromJson(h))
            .toList(),
        daily: (json['daily'] as List)
            .map((d) => DailyForecast.fromJson(d))
            .toList(),
        updateTime: DateTime.parse(json['updateTime']),
        source: json['source'] ?? 'unknown',
      );
}

class HourlyForecast {
  final String time; // e.g. "14:00"
  final double temperature;
  final int weatherCode;
  final String weatherText;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.weatherText,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'temperature': temperature,
        'weatherCode': weatherCode,
        'weatherText': weatherText,
      };

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => HourlyForecast(
        time: json['time'] ?? '',
        temperature: (json['temperature'] as num).toDouble(),
        weatherCode: (json['weatherCode'] as num).toInt(),
        weatherText: json['weatherText'] ?? '',
      );
}

class DailyForecast {
  final String date; // e.g. "周一 10/19"
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final String weatherText;
  final int weekday;
  final String monthDay;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    required this.weatherText,
    this.weekday = 1,
    this.monthDay = '',
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'tempMax': tempMax,
        'tempMin': tempMin,
        'weatherCode': weatherCode,
        'weatherText': weatherText,
      };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: json['date'] ?? '',
        tempMax: (json['tempMax'] as num).toDouble(),
        tempMin: (json['tempMin'] as num).toDouble(),
        weatherCode: (json['weatherCode'] as num).toInt(),
        weatherText: json['weatherText'] ?? '',
        weekday: json['weekday'] ?? 1,
        monthDay: json['monthDay'] ?? '',
      );
}

class CityItem {
  final String name;
  final double latitude;
  final double longitude;
  final String adminArea;

  CityItem({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.adminArea,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'adminArea': adminArea,
      };

  factory CityItem.fromJson(Map<String, dynamic> json) => CityItem(
        name: json['name'] ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        adminArea: json['adminArea'] ?? '',
      );
}
