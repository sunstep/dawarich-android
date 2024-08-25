import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dawarich/widgets/drawer.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  List<LatLng> _points = [];
  bool _isLoading = true;

  String? _endpoint;
  String? _apiKey;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchEndpointInfo();
    await _getCurrentLocation();
    await _loadToday();
  }

  Future<void> _fetchEndpointInfo() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();

    _endpoint = await storage.read(key: "host");
    _apiKey = await storage.read(key: "api_key");
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = const LatLng(0, 0);
        });
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadPreviousDay() async {

    DateTime previousDay = _selectedDate.subtract(const Duration(days: 1));

    setState(() {
      _selectedDate = DateTime(previousDay.year, previousDay.month, previousDay.day);
    });

    final data = await _fetchPoints();

    setState(() {
      _points = _parsePoints(data);
    });
  }

  Future<void> _loadNextDay() async {

    DateTime nextDay = _selectedDate.add(const Duration(days: 1));

    setState(() {
      _selectedDate = DateTime(nextDay.year, nextDay.month, nextDay.day);
    });

    final data = await _fetchPoints();

    setState(() {
      _points = _parsePoints(data);
    });
  }

  Future<void> _displayDatePicker() async {

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }

    final data = await _fetchPoints();

    setState(() {
      _points = _parsePoints(data);
    });
  }

  Future<void> _loadToday() async {

      final data = await _fetchPoints();

      setState(() {
        _points = _parsePoints(data);
        _isLoading = false;
      });

  }

  Future<List<dynamic>> _fetchPoints() async {

    setState(() {
      _points.clear();
    });

    final startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
            .toUtc()
            .toIso8601String();
    final endDate = DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    final uri = Uri.parse(
        '$_endpoint/api/v1/points?api_key=$_apiKey&start_at=$startDate&end_at=$endDate');
    final response = await get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load points');
    }
  }

  List<LatLng> _parsePoints(List<dynamic> data) {

    data.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    return data.map((point) {
      final latitude = double.parse(point['latitude']);
      final longitude = double.parse(point['longitude']);
      return LatLng(latitude, longitude);
    }).toList();
  }

  String _displayDate() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selectedDate == today) {
      return "Today";
    } else if (selectedDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('EEE, MMM d yyyy').format(_selectedDate);
    }
  }

  bool _isTodaySelected() {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  Widget _buildBottomSheet() {

    final textLarge = Theme.of(context).textTheme.bodyLarge;

    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.11,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                height: 5.0,
                width: 30.0,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            _loadPreviousDay();
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: TextButton(
                              onPressed: _displayDatePicker,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _displayDate(),
                                    style: textLarge,
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              )
                            ),
                          ),
                        ),
                        if (!_isTodaySelected())
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              _loadNextDay();
                            },
                          )
                        else
                          const SizedBox(width: 48)
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pageContent() {

    if (_currentLocation == const LatLng(0.0, 0.0) || _isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _currentLocation,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'app.dawarich',
              maxNativeZoom: 19,
            ),
            PolylineLayer(polylines: [
              Polyline(points: _points, strokeWidth: 4.0, color: Colors.blue)
            ])
          ],
        ),
        _buildBottomSheet()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Timeline", fontSize: 20),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }
}
