import 'package:dawarich/features/batch/presentation/models/local_point_viewmodel.dart';
import 'package:intl/intl.dart';

class LastPointViewModel {
  final String rawTimestamp;
  String get formattedTimestamp {
    return DateFormat('dd MMM yyyy HH:mm:ss')
        .format(DateTime.parse(rawTimestamp).toLocal());
  }

  final double longitude;
  final double latitude;

  LastPointViewModel({
    required this.rawTimestamp,
    required this.longitude,
    required this.latitude,
  });

  factory LastPointViewModel.fromPoint(LocalPointViewModel point) {
    final double longitude = point.geometry.coordinates[0];
    final double latitude = point.geometry.coordinates[1];
    return LastPointViewModel(
        rawTimestamp: point.properties.timestamp,
        longitude: longitude,
        latitude: latitude);
  }
}
