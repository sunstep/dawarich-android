import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dawarich/ui/models/local/last_point.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPageViewModel with ChangeNotifier {

  bool _isTrackingEnabled = false;
  int _pointsPerBatch = 50;
  int _trackingFrequency = 10; // in seconds
  int _desiredAccuracyMeters = 5; // in meters
  LocationAccuracy _locationAccuracy = LocationAccuracy.best;
  LastPoint? _lastPoint;

  bool get isTrackingEnabled => _isTrackingEnabled;
  int get pointsPerBatch => _pointsPerBatch;
  int get trackingFrequency => _trackingFrequency;
  int get desiredAccuracyMeters => _desiredAccuracyMeters;
  LocationAccuracy get locationAccuracy => _locationAccuracy;
  LastPoint? get lastPoint => _lastPoint;

  void toggleTracking(bool value) {
    _isTrackingEnabled = value;
    notifyListeners();
  }

  void setPointsPerBatch(int? value) {
    _pointsPerBatch = value?? 0;
    notifyListeners();
  }

  void setTrackingFrequency(int? value) {
    _trackingFrequency = value?? 0;

    notifyListeners();
  }

  void setLocationAccuracy(int? meters) {

    _desiredAccuracyMeters = meters?? 0;
    _mapLocationAccuracy();
    notifyListeners();
  }

  void _mapLocationAccuracy() {

    final int meters = desiredAccuracyMeters;

    if (Platform.isIOS) {

      if (meters <= 5) {
        _locationAccuracy = LocationAccuracy.bestForNavigation;
      } else if (meters <= 10) {
        _locationAccuracy = LocationAccuracy.best;
      } else if (meters <= 100) {
        _locationAccuracy = LocationAccuracy.high;
      } else if (meters <= 500) {
        _locationAccuracy = LocationAccuracy.medium;
      } else if (meters <= 1000) {
        _locationAccuracy = LocationAccuracy.low;
      } else {
        _locationAccuracy = LocationAccuracy.lowest;
      }
    } else if (Platform.isAndroid) {

      if (meters <= 100) {
        _locationAccuracy = LocationAccuracy.high;
      } else if (meters <= 500) {
        _locationAccuracy = LocationAccuracy.medium;
      } else if (meters <= 1000) {
        _locationAccuracy = LocationAccuracy.low;
      } else {
        _locationAccuracy = LocationAccuracy.lowest;
      }
    }
  }

  void updateLastPoint(LastPoint point) {
    _lastPoint = point;
    notifyListeners();
  }

}