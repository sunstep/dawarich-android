import 'package:dawarich/helpers/endpoint.dart';
import 'package:dawarich/models/slim_api_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dawarich/helpers/points.dart';
import 'package:intl/intl.dart';
import 'point_api.dart';

class MapContainer {

  String? _endpoint;
  String? _apiKey;

  DateTime selectedDate = DateTime.now();


  Future<void> fetchEndpointInfo(BuildContext context) async {

    EndpointResult endpointResult = Provider.of<EndpointResult>(context, listen: false);
    _endpoint = endpointResult.endPoint;
    _apiKey = endpointResult.apiKey;
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Future<List<SlimApiPoint>> fetchAllPoints(int perPage) async {

    final PointApi api = PointApi(_endpoint!, _apiKey!, selectedDate, selectedDate);
    final Map<String, String?> headers = await api.fetchHeaders(perPage);
    final int pages = int.parse(headers["x-total-pages"]!);
    final List<SlimApiPoint> allPoints = [];

    final List<Future<List<SlimApiPoint>>> responses = [];
    for (int page = 1; page <= pages; page++) {
      responses.add(api.fetchSlimPoints(perPage, page));
    }

    final List<List<SlimApiPoint>> results = await Future.wait(responses);

    for (List<SlimApiPoint> result in results){
      allPoints.addAll(result);
    }

    return allPoints;
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

  List<SlimApiPoint> mergePoints(List<SlimApiPoint> points){
    const double distanceThreshold = 15;
    final List<SlimApiPoint> mergedPoints = [];

    if (points.isNotEmpty) {
      LatLng currentPoint = LatLng(double.parse(points[0].latitude!), double.parse(points[0].longitude!));
      mergedPoints.add(points[0]);

      for (int i = 1; i < points.length; i++) {
        final nextPoint = LatLng(double.parse(points[i].latitude!), double.parse(points[i].longitude!));
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

  bool isTodaySelected() {
    final today = DateTime.now();
    return selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
  }

}
