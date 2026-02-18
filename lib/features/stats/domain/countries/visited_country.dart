
import 'visited_city.dart';

final class VisitedCountry {

  final String country;
  final List<VisitedCity> cities;

  const VisitedCountry({required this.country, this.cities = const []});

}