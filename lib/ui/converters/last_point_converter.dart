
import 'package:dawarich/domain/entities/local/last_point.dart';
import 'package:dawarich/ui/models/local/last_point_viewmodel.dart';
import 'package:intl/intl.dart';

extension LastPointToViewModel on LastPoint {

  LastPointViewModel toViewModel() {

    final formattedTimestamp = DateFormat('dd MMM yyyy HH:mm:ss')
        .format(DateTime.parse(timestamp).toLocal());
    return LastPointViewModel(
      timestamp: formattedTimestamp,
      longitude: longitude,
      latitude: latitude,
    );
  }
}

extension LastPointViewModelToEntity on LastPointViewModel {

  LastPoint toEntity() => LastPoint(timestamp: timestamp, longitude: longitude, latitude: latitude);
}