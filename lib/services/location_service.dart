import 'package:geolocator/geolocator.dart';

import '../models/weather.dart';
import 'app_exception.dart';

abstract class LocationService {
  Future<Coordinates> current();
}

/// Mengambil lokasi dari GPS perangkat.
class GpsLocationService implements LocationService {
  @override
  Future<Coordinates> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationIssue.serviceOff);
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw const LocationException(LocationIssue.denied);
    }
    if (perm == LocationPermission.deniedForever) {
      throw const LocationException(LocationIssue.deniedForever);
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return Coordinates(pos.latitude, pos.longitude);
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
