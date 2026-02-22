
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/features/stats/application/usecases/should_refresh_stats_usecase.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statsAutoRefreshCoordinatorProvider = Provider<StatsAutoRefreshCoordinator>((ref) {
  return StatsAutoRefreshCoordinator(ref);
});

final class StatsAutoRefreshCoordinator {
  final Ref _ref;
  bool _isRunning = false;

  StatsAutoRefreshCoordinator(this._ref);

  Future<void> onAppResumed() async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;

    try {
      final ShouldRefreshStatsUseCase shouldRefresh = await _ref.read(shouldRefreshStatsUseCaseProvider.future);
      final nowUtc = DateTime.now().toUtc();

      final mustRefresh = await shouldRefresh(nowUtc: nowUtc);
      if (mustRefresh) {
        await _ref.read(statsViewmodelProvider.notifier).refresh();
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[StatsAutoRefresh] failed: $e\n$s');
      }
    } finally {
      _isRunning = false;
    }
  }
}