
final class UserSettingsDto {
  final MapsSettingsDto? maps;
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

  const UserSettingsDto({
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

  factory UserSettingsDto.fromJson(Map<String, dynamic> json) => UserSettingsDto(
    maps: (json['maps'] is Map<String, dynamic>)
        ? MapsSettingsDto.fromJson(json['maps'] as Map<String, dynamic>)
        : null,
    fogOfWarMeters: _asInt(json['fog_of_war_meters']),
    metersBetweenRoutes: _asInt(json['meters_between_routes']),
    preferredMapLayer: json['preferred_map_layer'] as String?,
    speedColoredRoutes: json['speed_colored_routes'] as bool?,
    pointsRenderingMode: json['points_rendering_mode'] as String?,
    minutesBetweenRoutes: _asInt(json['minutes_between_routes']),
    timeThresholdMinutes: _asInt(json['time_threshold_minutes']),
    mergeThresholdMinutes: _asInt(json['merge_threshold_minutes']),
    liveMapEnabled: json['live_map_enabled'] as bool?,
    routeOpacity: _asDouble(json['route_opacity']),
    immichUrl: json['immich_url'] as String?,
    photoprismUrl: json['photoprism_url'] as String?,
    visitsSuggestionsEnabled: json['visits_suggestions_enabled'] as bool?,
    speedColorScale: json['speed_color_scale'],
    fogOfWarThreshold: json['fog_of_war_threshold'],
  );

  Map<String, dynamic> toJson() => {
    'maps': maps?.toJson(),
    'fog_of_war_meters': fogOfWarMeters,
    'meters_between_routes': metersBetweenRoutes,
    'preferred_map_layer': preferredMapLayer,
    'speed_colored_routes': speedColoredRoutes,
    'points_rendering_mode': pointsRenderingMode,
    'minutes_between_routes': minutesBetweenRoutes,
    'time_threshold_minutes': timeThresholdMinutes,
    'merge_threshold_minutes': mergeThresholdMinutes,
    'live_map_enabled': liveMapEnabled,
    'route_opacity': routeOpacity,
    'immich_url': immichUrl,
    'photoprism_url': photoprismUrl,
    'visits_suggestions_enabled': visitsSuggestionsEnabled,
    'speed_color_scale': speedColorScale,
    'fog_of_war_threshold': fogOfWarThreshold,
  };
}

final class MapsSettingsDto {
  final String? distanceUnit;
  const MapsSettingsDto({this.distanceUnit});

  factory MapsSettingsDto.fromJson(Map<String, dynamic> json) =>
      MapsSettingsDto(distanceUnit: json['distance_unit'] as String?);

  Map<String, dynamic> toJson() => {
    'distance_unit': distanceUnit,
  };
}

// helpers
int? _asInt(dynamic v) => v == null ? null : (v is int ? v : (v is num ? v.toInt() : (v is String ? int.tryParse(v) : null)));
double? _asDouble(dynamic v) => v == null ? null : (v is double ? v : (v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null)));