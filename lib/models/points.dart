import 'package:dawarich/models/point_geometry.dart';
import 'package:dawarich/models/point_properties.dart';
import 'package:http/http.dart' as http;
import 'point_creator.dart';

class Points {

  final List<PointCreator> pointsList;

  Points({required this.pointsList});

  Map<String, dynamic> _toJson() {
    return {
      'locations': pointsList.map((point) => point.toJson()).toList(),
    };
  }

  void newPoint(PointGeometry geometry, PointProperties properties){
    final PointCreator point = PointCreator(geometry: geometry, properties: properties);
    pointsList.add(point);
  }

  Future<bool> uploadPoints(String endpoint, String apiKey) async {
    final Uri url = Uri.parse("$endpoint/api/v1/overland/batches?api_key=$apiKey");

    final http.Response response = await http.post(
      url,
      body: _toJson()
    );

    if (response.statusCode == 200){
      return true;
    }

    return false;
  }
}
