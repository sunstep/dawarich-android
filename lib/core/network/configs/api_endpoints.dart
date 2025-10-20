abstract final class ApiEndpoints {
  static const _v1 = '/api/v1';

  // Areas
  static const String createArea = '$_v1/areas';
  static const String getAreas = '$_v1/areas';
  static String deleteArea(String id) => '$_v1/areas/$id';

  // Countries
  static const String visitedCities = '$_v1/countries/visited_cities';

  // Health
  static const String healthCheck = '$_v1/health';

  // Points
  static const String createPointBatch = '$_v1/points';
  static const String getTrackedMonths = '$_v1/points/tracked_months';
  static const String getPoints = '$_v1/points';
  static String deletePoint(String id) => '$_v1/points/$id';

  // Photos
  static const String getPhotos = '$_v1/photos';
  static String getPhotoThumbnail(String id) => '$_v1/photos/$id/thumbnail';

  // Settings
  static const String getSettings = '$_v1/settings';
  static const String updateSettings = '$_v1/settings';

  // Stats
  static const String getStats = '$_v1/stats';

  // Users
  static const String currentUser = '$_v1/users/me';
}