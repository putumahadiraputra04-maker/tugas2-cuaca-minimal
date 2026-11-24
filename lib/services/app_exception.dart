class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

enum LocationIssue { serviceOff, denied, deniedForever }

class LocationException implements Exception {
  const LocationException(this.issue);
  final LocationIssue issue;
}
