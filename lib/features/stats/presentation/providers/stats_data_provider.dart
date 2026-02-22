
import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_data_provider.g.dart';

@riverpod
AsyncValue<StatsUiModel?> statsData(Ref ref) {
  final stateAsync = ref.watch(statsViewmodelProvider);

  return stateAsync.whenData((state) => state?.stats);
}