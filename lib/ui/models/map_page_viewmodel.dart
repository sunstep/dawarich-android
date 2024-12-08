import 'package:flutter/material.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';


class MapViewModel with ChangeNotifier {

  final MapService _mapService;
  final LocationService _locationService;

  MapViewModel(this._mapService, this._locationService);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<LatLng> _points = [];
  List<LatLng> get points => _points;


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

    Position? position = await _locationService.getCurrentLocation();

    if (position != null) {
      setCurrentLocation(LatLng(position.latitude, position.longitude));
    }

    await loadToday();
  }

  Future<void> loadPreviousDay() async {

    DateTime previousDay = selectedDate.subtract(const Duration(days: 1));

    setIsLoading(true);
    clearPoints();
    _selectedDate = DateTime(previousDay.year, previousDay.month, previousDay.day);

    final List<LatLng> data = await _mapService.loadMap(selectedDate);

    setPoints(data);
    setIsLoading(false);
  }

  Future<void> loadToday() async {


    setIsLoading(true);
    clearPoints();

    final List<LatLng> data = await _mapService.loadMap(selectedDate);

    setPoints(data);
    setIsLoading(false);

  }

  Future<void> loadNextDay() async {

    setIsLoading(true);
    points.clear();

    DateTime nextDay = selectedDate.add(const Duration(days: 1));
    DateTime newDate = DateTime(nextDay.year, nextDay.month, nextDay.day);
    setSelectedDate(newDate);

    final List<LatLng> data = await _mapService.loadMap(selectedDate);

    setPoints(data);
    setIsLoading(false);
  }

  Future<void> processNewDate(DateTime pickedDate) async {

    if (pickedDate == selectedDate){
      return;
    }

    setSelectedDate(pickedDate);

    setIsLoading(true);
    clearPoints();




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

}