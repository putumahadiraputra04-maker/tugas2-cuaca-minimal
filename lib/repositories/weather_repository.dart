import '../models/weather.dart';
import '../services/app_exception.dart';
import '../services/weather_service.dart';

class WeatherRepository {
  WeatherRepository(this._service);
  final WeatherService _service;

  Future<WeatherData> getWeather(Coordinates coords) async {
    final json = await _service.fetchForecast(coords);
    try {
      return WeatherData.fromJson(json);
    } on FormatException {
      throw const AppException('Data cuaca tidak sesuai format.');
    }
  }
}
