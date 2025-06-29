import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:dawarich/features/tracking/presentation/models/last_point_viewmodel.dart';

extension LastPointToViewModel on LastPoint {
  LastPointViewModel toViewModel() {
    return LastPointViewModel(
      rawTimestamp: timestamp,
      longitude: longitude,
      latitude: latitude,
    );
  }
}

// extension LastPointViewModelToEntity on LastPointViewModel {
//
//   LastPoint toEntity() => LastPoint(timestamp: timestamp, longitude: longitude, latitude: latitude);
// }
