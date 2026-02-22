
import 'package:dawarich/features/stats/presentation/coordinators/stats_auto_refresh_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final class AppLifecycleController with WidgetsBindingObserver {
  final ProviderContainer _container;

  AppLifecycleController(this._container);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _container.read(statsAutoRefreshCoordinatorProvider).onAppResumed();
    }
  }
}