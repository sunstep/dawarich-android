import 'package:dawarich/core/platform/build_config_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The distribution flavor of the app.
enum DistributionFlavor { gms, foss }

/// Provider that exposes the compile-time build flavor.
/// This is set via buildConfigField in gradle and accessed via method channel.
final distributionFlavorProvider = FutureProvider<DistributionFlavor>((ref) async {
  final flavor = await BuildConfigChannel.getFlavor();
  return flavor == 'foss' ? DistributionFlavor.foss : DistributionFlavor.gms;
});

