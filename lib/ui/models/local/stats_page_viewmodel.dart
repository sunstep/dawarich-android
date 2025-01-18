
import 'package:dawarich/domain/entities/api/v1/stats/response/stats.dart';
import 'package:dawarich/application/services/stats_service.dart';
import 'package:dawarich/ui/models/api/v1/stats/response/stats_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

class StatsPageViewModel extends ChangeNotifier {

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

    switch (result) {
      case Some(value: Stats stats): {
        setStats(StatsViewModel.fromEntity(stats));
      }

      case None(): {

      }
    }

    setIsLoading(false);

  }
}