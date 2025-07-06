import 'package:country/country.dart';
import 'package:dawarich/core/application/services/api_point_service.dart';
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/domain/models/point/point_pair.dart';
import 'package:device_region/device_region.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option_result.dart';

class MapService {
  final ApiPointService _pointService;

  MapService(this._pointService);

  Future<List<LatLng>> loadMap(DateTime date) async {
    Option<List<SlimApiPoint>> result =
        await _pointService.getSlimPoints(startDate: date, endDate:  date, perPage:  1750);

    switch (result) {
      case Some(value: List<SlimApiPoint> points):
        {
          return prepPoints(points);
        }
      case None():
        {
          // TODO: HANDLE BOTTOMSHEET ERROR VIEW
          return [];
        }
    }
  }

  List<LatLng> prepPoints(List<SlimApiPoint> points) {
    final List<SlimApiPoint> sortedPoints = _pointService.sortPoints(points);
    final List<SlimApiPoint> mergedPoints = mergePoints(sortedPoints);
    return parsePoints(mergedPoints);
  }

  List<SlimApiPoint> mergePoints(List<SlimApiPoint> points) {
    const double distanceThreshold = 50;
    final List<SlimApiPoint> mergedPoints = [];

    if (points.isNotEmpty) {
      LatLng currentPoint = LatLng(double.parse(points[0].latitude!),
          double.parse(points[0].longitude!));
      mergedPoints.add(points[0]);

      for (int i = 1; i < points.length; i++) {
        final nextPoint = LatLng(double.parse(points[i].latitude!),
            double.parse(points[i].longitude!));
        final pointPair = PointPair(currentPoint, nextPoint);
        final double dist = pointPair.calculateDistance();

        if (dist >= distanceThreshold) {
          mergedPoints.add(points[i]);
          currentPoint = nextPoint;
        }
      }
    }

    return mergedPoints;
  }

  List<LatLng> parsePoints(List<SlimApiPoint> points) {
    return points.map((point) {
      final latitude = double.parse(point.latitude!);
      final longitude = double.parse(point.longitude!);
      return LatLng(latitude, longitude);
    }).toList();
  }

  Future<LatLng> getDefaultMapCenter() async {
    // Use sim:
    String? countryCode = await DeviceRegion.getSIMCountryCode();

    if (countryCode == null) {
      final dispatcher = WidgetsBinding.instance.platformDispatcher;

      final Locale locale = dispatcher.locale;
      countryCode = locale.countryCode ?? '';
    }

    // Look up a preset coordinate (or fallback to (0,0))
    return _centroidForIso(countryCode);
  }

  LatLng _centroidForIso(String iso) {
    final c = Countries.values.firstWhere(
      (e) => e.alpha2.toUpperCase() == iso.toUpperCase(),
      orElse: () => Countries.values.first, // fallback country
    );
    final coord = c.geo.coordinate;
    return LatLng(coord.latitude, coord.longitude);
  }
}
