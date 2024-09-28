import 'package:dawarich/containers/point_api.dart';
import 'package:dawarich/models/api_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:dawarich/helpers/endpoint.dart';


class PointsPageContainer extends ChangeNotifier {

  String? _endpoint;
  String? _apiKey;

  List<ApiPoint> points = [];
  List<ApiPoint> currentPoints = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  final int pointsPerPage = 100;
  final int pointsPerRequest = 1000;
  int currentPage = 1;
  int totalPages = 1;


  Future<void> fetchEndpointInfo(BuildContext context) async {

    EndpointResult endpointResult = Provider.of<EndpointResult>(context, listen: false);
    _endpoint = endpointResult.endPoint;
    _apiKey = endpointResult.apiKey;
  }

  Future<void> fetchPoints() async {

    PointApi api = PointApi(_endpoint!, _apiKey!, startDate, endDate);
    Map<String, String?> headersPerRequest = await api.fetchHeaders(pointsPerRequest);
    int totalPagesPerRequest = int.parse(headersPerRequest['x-total-pages']!);

    Map<String, String?> headersPerPage = await api.fetchHeaders(pointsPerPage);
    totalPages = int.parse(headersPerPage['x-total-pages']!);

    final List<Future<List<ApiPoint>>> responses = [];
    for (int page = 1; page <= totalPagesPerRequest; page++) {
      responses.add(api.fetchPoints(pointsPerRequest, page));
    }

    final List<List<ApiPoint>> results = await Future.wait(responses);

    for (List<ApiPoint> result in results){
      points.addAll(result);
    }

  }

  void setCurrentPagePoints() {
    final int start = (currentPage - 1) * pointsPerPage;
    final int end = start + pointsPerPage;

    if (start >= points.length) {
      currentPoints = [];
    }

    currentPoints = points.sublist(start, end > points.length ? points.length : end);
  }

  List<ApiPoint> getCurrentPagePoints() {
    final int start = (currentPage - 1) * pointsPerPage;
    final int end = start + pointsPerPage;

    if (start >= points.length) {
      return [];
    }

    return points.sublist(start, end > points.length ? points.length : end);
  }

  void navigateBack(){

  }

}