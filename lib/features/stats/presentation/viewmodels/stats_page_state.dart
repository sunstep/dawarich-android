import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';

final class StatsPageState {
  final StatsUiModel? stats;
  final DateTime? syncedAtUtc;

  const StatsPageState({
    required this.stats,
    required this.syncedAtUtc,
  });

  StatsPageState copyWith({
    StatsUiModel? stats,
    DateTime? syncedAtUtc,
  }) {
    return StatsPageState(
      stats: stats ?? this.stats,
      syncedAtUtc: syncedAtUtc ?? this.syncedAtUtc,
    );
  }
}