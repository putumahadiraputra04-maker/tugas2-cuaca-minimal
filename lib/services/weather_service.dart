import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';
import 'app_exception.dart';

abstract class WeatherService {
  Future<Map<String, dynamic>> fetchForecast(Coordinates coords);
}

/// Memanggil API Open-Meteo (tanpa API key).
class OpenMeteoService implements WeatherService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> fetchForecast(Coordinates c) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${c.latitude}',
      'longitude': '${c.longitude}',
      'current':
          'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode >= 500) {
        throw const AppException('Server sedang bermasalah. Coba lagi nanti.');
      }
      if (res.statusCode >= 400) {
        throw AppException('Permintaan ditolak (kode ${res.statusCode}).');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw const AppException('Koneksi terlalu lama. Coba lagi.');
    } on http.ClientException {
      throw const AppException('Tidak ada koneksi internet.');
    } on FormatException {
      throw const AppException('Data dari server tidak bisa dibaca.');
    }
  }
}
