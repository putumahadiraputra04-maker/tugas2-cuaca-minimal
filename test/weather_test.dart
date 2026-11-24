import 'package:cuaca_minimal/models/weather.dart';
import 'package:cuaca_minimal/repositories/weather_repository.dart';
import 'package:cuaca_minimal/services/app_exception.dart';
import 'package:cuaca_minimal/services/location_service.dart';
import 'package:cuaca_minimal/services/weather_service.dart';
import 'package:cuaca_minimal/viewmodels/weather_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

const _sample = {
  'current': {
    'temperature_2m': 29.4,
    'relative_humidity_2m': 78,
    'weather_code': 2,
    'wind_speed_10m': 9.5,
  },
  'daily': {
    'time': ['2026-11-18', '2026-11-19'],
    'weather_code': [2, 61],
    'temperature_2m_max': [31.0, 30.2],
    'temperature_2m_min': [24.0, 23.8],
  },
};

class FakeWeatherService implements WeatherService {
  FakeWeatherService({this.json, this.error});
  final Map<String, dynamic>? json;
  final AppException? error;

  @override
  Future<Map<String, dynamic>> fetchForecast(Coordinates coords) async {
    if (error != null) throw error!;
    return json!;
  }
}

class FakeLocation implements LocationService {
  FakeLocation({this.denied = false});
  final bool denied;

  @override
  Future<Coordinates> current() async {
    if (denied) throw const LocationException(LocationIssue.denied);
    return const Coordinates(-8.65, 115.21);
  }
}

WeatherViewModel _vm(WeatherService s, LocationService l) =>
    WeatherViewModel(repository: WeatherRepository(s), location: l);

void main() {
  test('fromJson membaca data cuaca dengan benar', () {
    final w = WeatherData.fromJson(_sample);
    expect(w.current.temperature, 29.4);
    expect(w.daily.length, 2);
    expect(w.daily[1].code, 61);
  });

  test('fromJson melempar FormatException bila data rusak', () {
    expect(() => WeatherData.fromJson({'foo': 1}), throwsFormatException);
  });

  test('ViewModel sukses memuat data', () async {
    final vm = _vm(FakeWeatherService(json: _sample), FakeLocation());
    await vm.load();
    expect(vm.state, ViewState.success);
    expect(vm.data!.daily.length, 2);
  });

  test('ViewModel menampilkan error saat API gagal', () async {
    final vm = _vm(
      FakeWeatherService(error: const AppException('Tidak ada koneksi internet.')),
      FakeLocation(),
    );
    await vm.load();
    expect(vm.state, ViewState.error);
    expect(vm.message, 'Tidak ada koneksi internet.');
  });

  test('ViewModel menangani izin lokasi ditolak lalu pakai lokasi cadangan',
      () async {
    final vm = _vm(FakeWeatherService(json: _sample), FakeLocation(denied: true));
    await vm.load();
    expect(vm.state, ViewState.locationBlocked);
    await vm.load(useDefault: true);
    expect(vm.state, ViewState.success);
  });
}
