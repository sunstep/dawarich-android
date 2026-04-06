import 'package:flutter_riverpod/flutter_riverpod.dart';

final featureFlagsProvider = Provider<FeatureFlags>((_) => const FeatureFlags());

class FeatureFlags {

  final bool visitedPlacesStatsEnabled;

  const FeatureFlags({
    this.visitedPlacesStatsEnabled = false,
  });

}