import 'dart:async';

import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/features/timeline/application/services/timeline_service.dart';
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

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  StreamSubscription<List<LocalPoint>>? _localPointSubscription;

  List<LatLng> _points = [];
  List<LatLng> get points => _points;

  void setAnimatedMapController(AnimatedMapController controller) {
    animatedMapController ??= controller;
  }

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
  }

  void setPoints(List<LatLng> points) {
    _points = points;
    notifyListeners();
  }

  void addPoints(List<LatLng> points) {
    _points.addAll(points);
    notifyListeners();
  }

  void clearPoints() {
    _points.clear();
    notifyListeners();
  }

  Future<void> initialize() async {

    loadToday();
    _resolveAndSetInitialLocation();

    final batchStream = await _localPointService.watchCurrentBatch();

    _localPointSubscription = batchStream.listen((points) {

      final List<SlimApiPoint> slimApiPoints = points.map((point) {
        return SlimApiPoint(
          latitude: point.geometry.latitude.toString(),
          longitude: point.geometry.longitude.toString(),
          timestamp: point.properties.timestamp.millisecondsSinceEpoch,
        );
      }).toList();
      final List<LatLng> localPointList = _mapService.prepPoints(slimApiPoints);
      addPoints(localPointList);
    });
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
  }

  Future<void> loadPreviousDay() async {
    setIsLoading(true);
    clearPoints();

    DateTime previousDay = selectedDate.subtract(const Duration(days: 1));
    setSelectedDate(
        DateTime(previousDay.year, previousDay.month, previousDay.day));

    await getAndSetPoints();

    setIsLoading(false);
  }

  Future<void> loadToday() async {
    setIsLoading(true);
    clearPoints();

    await getAndSetPoints();

    setIsLoading(false);
  }

  Future<void> loadNextDay() async {
    setIsLoading(true);
    clearPoints();

    DateTime nextDay = selectedDate.add(const Duration(days: 1));
    setSelectedDate(DateTime(nextDay.year, nextDay.month, nextDay.day));

    await getAndSetPoints();

    setIsLoading(false);
  }

  Future<void> processNewDate(DateTime pickedDate) async {
    if (pickedDate == selectedDate) {
      return;
    }

    setIsLoading(true);
    clearPoints();

    setSelectedDate(pickedDate);

    await getAndSetPoints();

    setIsLoading(false);
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
    if (currentLocation != null) {
      animatedMapController?.animateTo(
        dest: currentLocation!,
        zoom: animatedMapController?.mapController.camera.zoom,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }
}
