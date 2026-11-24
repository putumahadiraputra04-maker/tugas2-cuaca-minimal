import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/weather.dart';
import '../repositories/weather_repository.dart';
import '../services/app_exception.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../viewmodels/weather_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GpsLocationService _gps = GpsLocationService();
  late final WeatherViewModel _vm = WeatherViewModel(
    repository: WeatherRepository(OpenMeteoService()),
    location: _gps,
  );

  @override
  void initState() {
    super.initState();
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  String _blockedText(LocationIssue? issue) => switch (issue) {
        LocationIssue.serviceOff =>
          'GPS belum aktif. Aktifkan lokasi di perangkat Anda.',
        LocationIssue.deniedForever =>
          'Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.',
        _ => 'Izin lokasi ditolak. Lokasi dibutuhkan untuk menampilkan cuaca di sekitar Anda.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () => _vm.load(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => switch (_vm.state) {
            ViewState.loading => const Center(
                child: CircularProgressIndicator(color: kPrimary),
              ),
            ViewState.success => _Content(vm: _vm),
            ViewState.error => _Message(
                icon: Icons.cloud_off,
                text: _vm.message,
                actions: [
                  FilledButton(
                    onPressed: () => _vm.load(),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ViewState.locationBlocked => _Message(
                icon: Icons.location_off,
                text: _blockedText(_vm.issue),
                actions: [
                  FilledButton(
                    onPressed: () => _vm.load(),
                    child: const Text('Coba lagi'),
                  ),
                  if (_vm.issue == LocationIssue.deniedForever)
                    OutlinedButton(
                      onPressed: _gps.openSettings,
                      child: const Text('Buka pengaturan'),
                    ),
                  OutlinedButton(
                    onPressed: () => _vm.load(useDefault: true),
                    child: const Text('Pakai lokasi Denpasar'),
                  ),
                ],
              ),
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.vm});
  final WeatherViewModel vm;

  @override
  Widget build(BuildContext context) {
    final w = vm.data!;
    final c = vm.coords!;
    return RefreshIndicator(
      color: kPrimary,
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _NowCard(current: w.current),
          const SizedBox(height: 8),
          Text(
            'Lokasi: ${c.latitude.toStringAsFixed(3)}, ${c.longitude.toStringAsFixed(3)}',
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          const Text('7 hari ke depan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          for (final d in w.daily) _DayRow(day: d),
          const SizedBox(height: 16),
          const Text('Data: Open-Meteo.com (CC BY 4.0)',
              style: TextStyle(color: kMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({required this.current});
  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${current.temperature.round()}°',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w300)),
                Text(weatherLabel(current.code),
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 12),
                Text(
                  'Lembap ${current.humidity}%  ·  Angin ${current.windSpeed.round()} km/j',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(weatherIcon(current.code), color: Colors.white, size: 64),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});
  final DailyForecast day;

  static const _names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(_names[day.date.weekday - 1],
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Icon(weatherIcon(day.code), color: kPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(weatherLabel(day.code))),
          Text('${day.maxTemp.round()}°',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('${day.minTemp.round()}°',
              style: const TextStyle(color: kMuted)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(
      {required this.icon, required this.text, required this.actions});
  final IconData icon;
  final String text;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: kPrimary),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
