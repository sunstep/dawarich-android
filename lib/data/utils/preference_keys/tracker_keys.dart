
class TrackerKeys {

  static String automaticTrackingKey(int userId) => "${userId}_automaticTracking";
  static String pointsPerBatchKey(int userId) => "${userId}_pointsPerBatch";
  static String trackingFrequencyKey(int userId) => "${userId}_trackingFrequency";
  static String locationAccuracyKey(int userId) => "${userId}_locationAccuracy";
  static String minimumPointDistanceKey(int userId) => "${userId}_minimumPointDistance";
  static String trackerIdKey(int userId) => "${userId}_trackerId";


}