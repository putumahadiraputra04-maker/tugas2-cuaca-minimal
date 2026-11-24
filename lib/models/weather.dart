import 'package:flutter/material.dart';

class Coordinates {
  const Coordinates(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.code,
  });

  final double temperature;
  final int humidity;
  final double windSpeed;
  final int code;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      code: (json['weather_code'] as num).toInt(),
    );
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.code,
    required this.maxTemp,
    required this.minTemp,
  });

  final DateTime date;
  final int code;
  final double maxTemp;
  final double minTemp;
}

class WeatherData {
  const WeatherData({required this.current, required this.daily});

  final CurrentWeather current;
  final List<DailyForecast> daily;

  /// Membaca respons Open-Meteo. Melempar [FormatException] bila bentuknya tidak sesuai.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    try {
      final current = CurrentWeather.fromJson(
        json['current'] as Map<String, dynamic>,
      );
      final d = json['daily'] as Map<String, dynamic>;
      final dates = (d['time'] as List).cast<String>();
      final codes = d['weather_code'] as List;
      final maxes = d['temperature_2m_max'] as List;
      final mins = d['temperature_2m_min'] as List;

      final daily = <DailyForecast>[
        for (var i = 0; i < dates.length; i++)
          DailyForecast(
            date: DateTime.parse(dates[i]),
            code: (codes[i] as num).toInt(),
            maxTemp: (maxes[i] as num).toDouble(),
            minTemp: (mins[i] as num).toDouble(),
          ),
      ];
      return WeatherData(current: current, daily: daily);
    } catch (_) {
      throw const FormatException('Data cuaca tidak sesuai format.');
    }
  }
}

/// Kode cuaca WMO -> teks Indonesia.
String weatherLabel(int code) {
  if (code == 0) return 'Cerah';
  if (code <= 3) return 'Berawan';
  if (code == 45 || code == 48) return 'Berkabut';
  if (code >= 51 && code <= 57) return 'Gerimis';
  if (code >= 61 && code <= 67) return 'Hujan';
  if (code >= 80 && code <= 82) return 'Hujan lokal';
  if (code >= 95) return 'Badai petir';
  return 'Berawan';
}

IconData weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny_outlined;
  if (code <= 3) return Icons.cloud_outlined;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 95) return Icons.thunderstorm_outlined;
  if (code >= 51) return Icons.water_drop_outlined;
  return Icons.cloud_outlined;
}
