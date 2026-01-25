import 'dart:async';

import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/point_pair.dart';
import 'package:dawarich/features/batch/application/usecases/watch_current_batch_usecase.dart';
import 'package:dawarich/features/timeline/application/helpers/timeline_points_processor.dart';
import 'package:dawarich/features/timeline/application/usecases/get_default_map_center_usecase.dart';
import 'package:dawarich/features/timeline/application/usecases/load_timeline_usecase.dart';
import 'package:dawarich/features/timeline/domain/models/day_map_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

final class TimelineViewModel extends ChangeNotifier {
  final LoadTimelineUseCase _loadTimelineUseCase;
  final TimelinePointsProcessor _timelinePointsProcessor;
  final GetDefaultMapCenterUseCase _getDefaultMapCenterUseCase;
  final WatchCurrentBatchUseCase _watchCurrentBatch;

  AnimatedMapController? animatedMapController;

  TimelineViewModel(
    this._loadTimelineUseCase,
    this._timelinePointsProcessor,
    this._getDefaultMapCenterUseCase,
    this._watchCurrentBatch,
  );

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  LatLng? _pendingCenter;
  bool _mapReady = false;
  LatLng? _lastCameraTarget;
  final double _epsilon = 1e-7;
  final double _epsilonMeters = 5.0;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  StreamSubscription<List<LocalPoint>>? _localPointSubscription;

  List<LatLng> _points = [];
  List<LatLng> get points => _points;

  List<LocalPoint> _lastLocalBatch = const [];

  List<LatLng> _localPoints = [];
  List<LatLng> get localPoints => _localPoints;

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCurrentLocation(LatLng currentLocation) {
    _currentLocation = currentLocation;
    notifyListeners();
  }

  void setSelectedDate(DateTime selectedDate) {
    _selectedDate = selectedDate;
    notifyListeners();
    _rebuildLocalPoints();
  }

  void setPoints(List<LatLng> points) {
    _points = points;
    notifyListeners();
  }

  void addPoints(List<LatLng> points) {
    _points.addAll(points);
    notifyListeners();
  }

  void setLocalPoints(List<LatLng> points) {
    _localPoints = points;
    notifyListeners();
  }

  void addLocalPoints(List<LatLng> points) {
    _localPoints.addAll(points);
    notifyListeners();
  }

  void clearPoints() {
    _points.clear();
    notifyListeners();
  }

  void markMapReady() {
    _mapReady = true;

    final pending = _pendingCenter;
    if (pending != null) {
      _pendingCenter = null;
      _animateTo(pending);
    }
  }

  void setAnimatedMapController(AnimatedMapController controller) {
    final bool wasNull = animatedMapController == null;
    animatedMapController ??= controller;

    if (!wasNull) {
      return;
    }

    final pendingCenter = _pendingCenter;

    if (_mapReady && pendingCenter != null) {
      _animateTo(pendingCenter);
      _pendingCenter = null;
    }
  }

  bool _sameTarget(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < _epsilon &&
      (a.longitude - b.longitude).abs() < _epsilon;

  void _animateTo(LatLng dest) {
    if (_lastCameraTarget != null && _sameTarget(_lastCameraTarget!, dest)) {
      return;
    }

    final AnimatedMapController? controller = animatedMapController;

    if (!_mapReady || controller == null) {
      _pendingCenter = dest;
      return;
    }

    final double zoom = controller.mapController.camera.zoom;

    animatedMapController?.animateTo(
      dest: dest,
      zoom: zoom,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
    );

    _lastCameraTarget = dest;
  }

  Future<void> initialize() async {
    _resolveAndSetInitialLocation();
    await loadToday();

    try {
      final batchStream = await _watchCurrentBatch();
      _localPointSubscription = batchStream.listen((points) {
        _lastLocalBatch = points;
        _rebuildLocalPoints();
      });
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint("[TimelineViewModel] watchCurrentBatch failed: $e\n$s");
      }
    }
  }

  void _rebuildLocalPoints({int? cutoffMs}) {
    final d = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final slim = _lastLocalBatch.where((p) {
      final ts = p.properties.timestamp;
      final day = DateTime(ts.year, ts.month, ts.day);
      if (day != d) return false;

      if (cutoffMs != null && ts.millisecondsSinceEpoch <= cutoffMs) {
        return false;
      }
      return true;
    }).map((p) => SlimApiPoint(
      latitude:  p.geometry.latitude.toString(),
      longitude: p.geometry.longitude.toString(),
      timestamp: p.properties.timestamp.millisecondsSinceEpoch ~/ 1000,
    )).toList();

    slim.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    final List<LatLng> local = _timelinePointsProcessor.processPoints(slim);

    setLocalPoints(local);
    _stitchLocalPoints();
  }

  void _stitchLocalPoints() {
    if (_points.isNotEmpty && _localPoints.isNotEmpty) {
      final firstLocalPoint = _localPoints.first;
      final lastApiPoint = _points.last;

      PointPair pair = PointPair(lastApiPoint, firstLocalPoint);
      final distance = pair.calculateDistance();

      if (distance > _epsilonMeters) {
        _localPoints.insert(0, lastApiPoint);
      }
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint("[TimelineViewModel] Disposing...");
    }

    _localPointSubscription?.cancel();
    super.dispose();
  }

  Future<void> _resolveAndSetInitialLocation() async {
    final center = await _getDefaultMapCenterUseCase.call();
    setCurrentLocation(center);
  }

  Future<void> getAndSetPoints() async {
    final DayMapData day = await _loadTimelineUseCase(selectedDate);
    setPoints(day.points);
    _rebuildLocalPoints(cutoffMs: day.lastTimestampMs);

    if (day.points.isNotEmpty) {
      _animateTo(day.points.first);
    }
  }

  Future<void> loadPreviousDay() async {
    try {
      setIsLoading(true);
      clearPoints();

      DateTime previousDay = selectedDate.subtract(const Duration(days: 1));
      setSelectedDate(
          DateTime(previousDay.year, previousDay.month, previousDay.day));

      await getAndSetPoints();
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> loadToday() async {
    try {
      setIsLoading(true);
      clearPoints();

      await getAndSetPoints();
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> loadNextDay() async {
    try {
      setIsLoading(true);
      clearPoints();

      DateTime nextDay = selectedDate.add(const Duration(days: 1));
      setSelectedDate(DateTime(nextDay.year, nextDay.month, nextDay.day));

      await getAndSetPoints();
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> processNewDate(DateTime pickedDate) async {
    if (pickedDate == selectedDate) {
      return;
    }

    try {
      setIsLoading(true);
      clearPoints();

      setSelectedDate(pickedDate);

      await getAndSetPoints();
    } finally {
      setIsLoading(false);
    }
  }

  bool isTodaySelected() {
    final today = DateTime.now();
    return selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
  }

  String displayDate() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (isTodaySelected()) {
      return "Today";
    } else if (selectedDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('EEE, MMM d yyyy').format(selectedDate);
    }
  }

  Future<void> zoomIn() async {
    await animatedMapController?.animatedZoomIn();
  }

  Future<void> zoomOut() async {
    await animatedMapController?.animatedZoomOut();
  }

  void centerMap() {
    final user = currentLocation;

    if (user == null) {
      return;
    }

    if (_lastCameraTarget != null && _sameTarget(_lastCameraTarget!, user)) {
      return;
    }

    final controller = animatedMapController;

    if (!_mapReady || controller == null) {
      _pendingCenter = user;
      return;
    }

    final double zoom = controller.mapController.camera.zoom;

    controller.animateTo(
      dest: user,
      zoom: zoom,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
    );

    _lastCameraTarget = user;
  }
}
