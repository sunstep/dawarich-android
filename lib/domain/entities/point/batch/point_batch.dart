import 'point.dart';

abstract class PointBatch {

  List<Point> get points;

  // bool validate();

  Map<String, dynamic> toJson();
}