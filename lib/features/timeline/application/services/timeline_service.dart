import 'package:country/country.dart';
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/domain/models/point/point_pair.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/timeline/application/converters/slim_point_converter.dart';
import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';
import 'package:device_region/device_region.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option_result.dart';

class MapService {
  final IApiPointRepository _apiPointRepository;

  MapService(this._apiPointRepository);

  Future<List<LatLng>> loadMap(DateTime date) async {

    final start = DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime.utc(date.year, date.month, date.day, 23, 59, 59);

    Option<List<SlimApiPointDTO>> result =
        await _apiPointRepository.getSlimPoints(
            startDate: start,
            endDate:  end,
            perPage:  1750
        );

    if (result case Some(value: final List<SlimApiPointDTO> pointDtos)) {
      List<SlimApiPoint> slimPoints = pointDtos
          .map((dto) => dto.toDomain())
          .toList();
      return prepPoints(slimPoints);
    }

    return [];
  }


  List<LatLng> prepPoints(List<SlimApiPoint> points) {
    final List<SlimApiPoint> sortedPoints = sortPoints(points);
    final List<SlimApiPoint> mergedPoints = mergePoints(sortedPoints);
    return parsePoints(mergedPoints);
  }

  List<SlimApiPoint> sortPoints(List<SlimApiPoint> data) {
    if (data.isEmpty) {
      return [];
    }

    data.sort((a, b) {
      int? timestampA = a.timestamp!;
      int? timestampB = b.timestamp!;

      return timestampA.compareTo(timestampB);
    });

    return data;
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
    // Try real GPS position first
    if (await Geolocator.isLocationServiceEnabled()) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        try {
          final current = await Geolocator.getCurrentPosition();
          return LatLng(current.latitude, current.longitude);
        } catch (_) {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) {
            return LatLng(last.latitude, last.longitude);
          }
        }
      }
    }

    // GPS failed → fallback to SIM/locale-based default
    String? countryCode = await DeviceRegion.getSIMCountryCode();

    if (countryCode == null) {
      final dispatcher = WidgetsBinding.instance.platformDispatcher;
      final Locale locale = dispatcher.locale;
      countryCode = locale.countryCode ?? '';
    }

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
