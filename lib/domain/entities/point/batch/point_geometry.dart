abstract class PointGeometry {
  String get type;
  List<double> get coordinates;

  Map<String, dynamic> toJson();
}
