import 'package:dawarich/features/stats/domain/stats.dart';
import 'package:dawarich/features/stats/application/services/stats_service.dart';
import 'package:dawarich/features/stats/presentation/converters/stats_page_model_converter.dart';
import 'package:dawarich/features/stats/presentation/models/stats_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class StatsPageViewModel extends ChangeNotifier {
  final StatsService _statsService;
  StatsPageViewModel(this._statsService);

  bool _isLoading = true;
  StatsViewModel? _stats;

  bool get isLoading => _isLoading;
  StatsViewModel? get stats => _stats;

  void setIsLoading(bool trueOrFalse) {
    _isLoading = trueOrFalse;
    notifyListeners();
  }

  void setStats(StatsViewModel stats) {
    _stats = stats;
    notifyListeners();
  }

  void clearStats() {
    _stats = null;
    notifyListeners();
  }

  Future<void> refreshStats() async {
    setIsLoading(true);
    clearStats();

    await fetchStats();
  }

  Future<void> fetchStats() async {
    Option<Stats> result = await _statsService.getStats();

    if (result case Some(value: final Stats stats)) {
      final StatsViewModel statsVm = stats.toViewModel();
      setStats(statsVm);
    }

    setIsLoading(false);
  }
}
