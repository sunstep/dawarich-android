import 'package:dawarich/containers/point_api.dart';
import 'package:dawarich/models/api_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:dawarich/helpers/endpoint.dart';


class PointsPageContainer {

  String? _endpoint;
  String? _apiKey;

  List<ApiPoint> points = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  final int pointsPerPage = 100;
  int currentPage = 1;
  int totalPages = 1;




  Future<void> fetchEndpointInfo(BuildContext context) async {

    EndpointResult endpointResult = Provider.of<EndpointResult>(context, listen: false);
    _endpoint = endpointResult.endPoint;
    _apiKey = endpointResult.apiKey;
  }

  Future<void> fetchPoints(int perPage, int page) async {
    PointApi api = PointApi(_endpoint!, _apiKey!, startDate, endDate);

    Map<String, String?> headers = await api.fetchHeaders(pointsPerPage);
    totalPages = int.parse(headers['x-total-pages']!);

    points = await api.fetchPoints(perPage, page);
  }

}