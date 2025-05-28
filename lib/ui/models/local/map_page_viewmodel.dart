import 'package:flutter/material.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';


class MapViewModel with ChangeNotifier {

  final MapService _mapService;
  final LocationService _locationService;
  AnimatedMapController? animatedMapController;

  MapViewModel(this._mapService, this._locationService);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

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

  void clearPoints() {
    _points.clear();
    notifyListeners();
  }

  Future<void> initialize() async {

    if (!await Geolocator.isLocationServiceEnabled()) {
      setCurrentLocation(await _mapService.getDefaultMapCenter());
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setCurrentLocation(await _mapService.getDefaultMapCenter());
      return;
    }

    Position? position;

    try {
      position = await _locationService.getCurrentLocation();
    } catch (_) {
      setCurrentLocation(await _mapService.getDefaultMapCenter());
    }

    position ??= await Geolocator.getLastKnownPosition();

    if (position != null) {
      setCurrentLocation(
        LatLng(position.latitude, position.longitude),
      );
    } else {
      setCurrentLocation(await _mapService.getDefaultMapCenter());
    }

    await loadToday();
  }

  Future<void> getAndSetPoints() async {

    final List<LatLng> data = await _mapService.loadMap(selectedDate);
    setPoints(data);
  }

  Future<void> loadPreviousDay() async {

    setIsLoading(true);
    clearPoints();

    DateTime previousDay = selectedDate.subtract(const Duration(days: 1));
    setSelectedDate(DateTime(previousDay.year, previousDay.month, previousDay.day));

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

    if (pickedDate == selectedDate){
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