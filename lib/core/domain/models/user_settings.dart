import 'package:dawarich/core/domain/models/map_settings.dart';

final class UserSettings {
  final MapsSettings? maps;
  final int? fogOfWarMeters;
  final int? metersBetweenRoutes;
  final String? preferredMapLayer;
  final bool? speedColoredRoutes;
  final String? pointsRenderingMode;
  final int? minutesBetweenRoutes;
  final int? timeThresholdMinutes;
  final int? mergeThresholdMinutes;
  final bool? liveMapEnabled;
  final double? routeOpacity;
  final String? immichUrl;
  final String? photoprismUrl;
  final bool? visitsSuggestionsEnabled;
  final dynamic speedColorScale;
  final dynamic fogOfWarThreshold;

  const UserSettings({
    this.maps,
    this.fogOfWarMeters,
    this.metersBetweenRoutes,
    this.preferredMapLayer,
    this.speedColoredRoutes,
    this.pointsRenderingMode,
    this.minutesBetweenRoutes,
    this.timeThresholdMinutes,
    this.mergeThresholdMinutes,
    this.liveMapEnabled,
    this.routeOpacity,
    this.immichUrl,
    this.photoprismUrl,
    this.visitsSuggestionsEnabled,
    this.speedColorScale,
    this.fogOfWarThreshold,
  });


}