import 'dart:async';

import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/features/timeline/application/services/timeline_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

final class TimelineViewModel extends ChangeNotifier {

  final MapService _mapService;
  final LocalPointService _localPointService;
  AnimatedMapController? animatedMapController;

  TimelineViewModel(this._mapService, this._localPointService);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  LatLng? _pendingCenter;
  bool _mapReady = false;
  LatLng? _lastCameraTarget;
  final double _epsilon = 1e-7;

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
    _applyLocalPointsForSelectedDay();
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
    loadToday();

    final batchStream = await _localPointService.watchCurrentBatch();

    _localPointSubscription = batchStream.listen((points) {

      _lastLocalBatch = points;
      _applyLocalPointsForSelectedDay();
    });
  }

  void _applyLocalPointsForSelectedDay() {
    final DateTime d = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final List<SlimApiPoint> slimForDay = _lastLocalBatch.where((p) {
      final ts = p.properties.timestamp;
      final day = DateTime(ts.year, ts.month, ts.day);
      return day == d;
    }).map((p) => SlimApiPoint(
      latitude: p.geometry.latitude.toString(),
      longitude: p.geometry.longitude.toString(),
      timestamp: p.properties.timestamp.millisecondsSinceEpoch,
    )).toList();

    final List<LatLng> localPointList = _mapService.prepPoints(slimForDay);
    setLocalPoints(localPointList);
  }

  @override
  void dispose() {

    if (kDebugMode) {
      debugPrint("[TimelineViewModel] Disposing...");
    }

    animatedMapController?.dispose();
    _localPointSubscription?.cancel();
    super.dispose();
  }

  Future<void> _resolveAndSetInitialLocation() async {
    final center = await _mapService.getDefaultMapCenter();
    setCurrentLocation(center);
  }

  Future<void> getAndSetPoints() async {
    final List<LatLng> data = await _mapService.loadMap(selectedDate);
    setPoints(data);
    if (data.isNotEmpty) {
      _animateTo(data.first);
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
