/// IDs used to identify each permission across the onboarding flow.
abstract final class PermissionIds {
  static const String notification = 'notification';
  static const String locationAlways = 'location_always';
  static const String batteryOptimization = 'battery_optimization';
}

/// Represents a single permission the user must grant during onboarding.
final class PermissionItem {
  final String id;
  final String title;
  final String description;
  final bool granted;

  const PermissionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.granted,
  });

  PermissionItem copyWith({bool? granted}) {
    return PermissionItem(
      id: id,
      title: title,
      description: description,
      granted: granted ?? this.granted,
    );
  }
}


