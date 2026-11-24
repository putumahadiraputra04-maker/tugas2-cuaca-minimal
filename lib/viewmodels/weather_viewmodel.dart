import 'package:flutter/foundation.dart';

import '../models/weather.dart';
import '../repositories/weather_repository.dart';
import '../services/app_exception.dart';
import '../services/location_service.dart';

enum ViewState { loading, success, error, locationBlocked }

/// Lokasi cadangan (Denpasar) bila izin GPS ditolak.
const kDefaultLocation = Coordinates(-8.6705, 115.2126);

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required WeatherRepository repository,
    required LocationService location,
  })  : _repo = repository,
        _location = location;

  final WeatherRepository _repo;
  final LocationService _location;

  ViewState state = ViewState.loading;
  WeatherData? data;
  Coordinates? coords;
  String message = '';
  LocationIssue? issue;

  Future<void> load({bool useDefault = false}) async {
    state = ViewState.loading;
    notifyListeners();

    try {
      coords = useDefault ? kDefaultLocation : await _location.current();
      data = await _repo.getWeather(coords!);
      state = ViewState.success;
    } on LocationException catch (e) {
      issue = e.issue;
      state = ViewState.locationBlocked;
    } on AppException catch (e) {
      message = e.message;
      state = ViewState.error;
    } catch (_) {
      message = 'Terjadi kesalahan. Coba lagi.';
      state = ViewState.error;
    }
    notifyListeners();
  }
}
