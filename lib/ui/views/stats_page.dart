import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {

  String? _endpoint;
  String? _apiKey;

  bool _isLoading = true;

  final Map<String, int?> _stats = {
    "totalDistanceKm": null,
    "totalPointsTracked": null,
    "totalReverseGeocodedPoints": null,
    "totalCountriesVisited": null,
    "totalCitiesVisited": null,
  };

  List<Map<String, dynamic>> _yearlyStats = [];
  List<Map<String, dynamic>> _monthlyStats = [];

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {

    await _fetchEndpointInfo();
    await _fetchStats();
  }

  Future<void> _fetchEndpointInfo() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    _endpoint = await storage.read(key: "host");
    _apiKey = await storage.read(key: "api_key");
  }

  Widget _pageContent(){

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = Theme.of(context).dividerColor;
    final textLarge = Theme.of(context).textTheme.bodyLarge;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 20),
          Center(
            child:
            ElevatedButton(
              onPressed: _isLoading? null : _refreshStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: borderColor,
                ),
              ),
              child: Text(
                'Update stats',
                style: textLarge,
              ),
            ),
          ),
          const SizedBox(height: 20),
          //_buildYearlyStats(),
        ],
      ),
    );
  }

  Future<void> _refreshStats() async {

    setState(() {

      _isLoading = true;
      _stats.clear();
    });

    await _fetchStats();
  }

  Future<void> _fetchStats() async {


    final uri = Uri.parse("$_endpoint/api/v1/stats?api_key=$_apiKey");
    final response = await http.get(uri);

    final jsonStats = jsonDecode(response.body);

    setState(() {
      _stats["totalDistanceKm"] = jsonStats["totalDistanceKm"] ?? 0;
      _stats["totalPointsTracked"] = jsonStats["totalPointsTracked"] ?? 0;
      _stats["totalReverseGeocodedPoints"] = jsonStats["totalReverseGeocodedPoints"] ?? 0;
      _stats["totalCountriesVisited"] = jsonStats["totalCountriesVisited"] ?? 0;
      _stats["totalCitiesVisited"] = jsonStats["totalCitiesVisited"] ?? 0;

      _yearlyStats = List<Map<String, dynamic>>.from(jsonStats["yearlyStats"]);

      _monthlyStats = _yearlyStats.map((yearStats) {
        return {
          "year": yearStats["year"],
          "monthlyDistances": yearStats["monthlyDistanceKm"],
        };
      }).toList();

      _isLoading = false;
    });

  }

  Widget _buildHeaderSection() {

    List<Widget> statItems = [
      _buildHeaderItem(_isLoading? null : '${_stats["totalCountriesVisited"]}', 'Countries visited', Colors.purple, 150, 90),
      _buildHeaderItem(_isLoading? null : '${_stats["totalCitiesVisited"]}', 'Cities visited', Colors.green, 150, 90),
      _buildHeaderItem(_isLoading? null : '${_stats["totalPointsTracked"]}', 'Geopoints Tracked', Colors.pink, 150, 90),
      _buildHeaderItem(_isLoading? null : '${_stats["totalReverseGeocodedPoints"]}', 'Reverse geocoded', Colors.orange, 150, 90),
      _buildHeaderItem(_isLoading? null : '${_stats["totalDistanceKm"]} km', 'Total distance', Colors.blue, 325, 90),
    ];

    return Column(
      children: [
        Wrap(
          spacing: 20.0,
          runSpacing: 20.0,
          alignment: WrapAlignment.center,
          children: statItems.length.isEven
              ? statItems
              : statItems.sublist(0, statItems.length - 1),
        ),
        if (statItems.length.isOdd)
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              statItems.last,
            ],
          ),
      ],
    );
  }

  Widget _buildHeaderItem(String? value, String label, Color color, double? width, double? height) {

    final textSmall = Theme.of(context).textTheme.bodySmall;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: value == null
                ? Container(
              width: 40.0,
              height: 20.0,
              color: Colors.grey.shade300,
            )
                : Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              key: ValueKey<String?>(value),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textSmall,
          ),
        ],
      ),
    );
  }

  // Widget _buildYearlyStats() {
  //
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Stats", fontSize: 40),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }

}
