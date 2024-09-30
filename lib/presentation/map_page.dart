import 'package:dawarich/helpers/point_populator.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/widgets/drawer.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dawarich/containers/map.dart';
import 'package:dawarich/models/slim_api_point.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final MapContainer _container = MapContainer();
  final PointPopulator _populator = PointPopulator();
  LatLng? _currentLocation;
  List<LatLng> _points = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _container.fetchEndpointInfo(context);
    Position? position = await _populator.getCurrentLocation();

    if (position != null) {
      if (mounted){
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    }
    await _loadToday();
  }

  Future<void> _loadPreviousDay() async {

    DateTime previousDay = _container.selectedDate.subtract(const Duration(days: 1));

    if (mounted){
      setState(() {
        _isLoading = true;
        _points.clear();
        _container.selectedDate = DateTime(previousDay.year, previousDay.month, previousDay.day);
      });
    }

    final List<SlimApiPoint> data = await _container.fetchAllPoints(1750);

    if (mounted){
      setState(() {
        _points = _container.prepPoints(data);
        _isLoading = false;
      });
    }

  }

  Future<void> _loadToday() async {

    if (mounted){
      setState(() {
        _isLoading =  true;
        _points.clear();
      });
    }

    final List<SlimApiPoint> data = await _container.fetchAllPoints(1750);

    if (mounted){
      setState(() {
        _points = _container.prepPoints(data);
        _isLoading = false;
      });
    }


  }

  Future<void> _loadNextDay() async {

    DateTime nextDay = _container.selectedDate.add(const Duration(days: 1));

    if (mounted){
      setState(() {
        _isLoading = true;
        _points.clear();
        _container.selectedDate = DateTime(nextDay.year, nextDay.month, nextDay.day);
      });
    }


    final List<SlimApiPoint> data = await _container.fetchAllPoints(1750);

    if (mounted){
      setState(() {
        _points = _container.prepPoints(data);
        _isLoading = false;
      });
    }

  }

  Future<void> _displayDatePicker() async {

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _container.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null || pickedDate == _container.selectedDate) {
      return;
    }

    if (mounted){
      setState(() {
        _isLoading = true;
        _points.clear();
        _container.selectedDate = pickedDate;
      });
    }


    final List<SlimApiPoint> data = await _container.fetchAllPoints(1750);

    if (mounted){
      setState(() {

        _points = _container.prepPoints(data);
        _isLoading = false;
      });
    }

  }

  Widget _buildBottomSheet() {

    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.11,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return _bottomsheetContent(context, scrollController);
      },
    );
  }

  Widget _bottomsheetContent(BuildContext context, ScrollController scrollController){

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
            width: 25.0,
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
                                _container.displayDate(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          )
                        ),
                      ),
                    ),
                    if (!_container.isTodaySelected())
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
                ),
                _isLoading? const Center(child: CircularProgressIndicator(color: Colors.cyan)) : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageContent() {

    if (_currentLocation == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _currentLocation!,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=NWn5VTZI9avXmOoeAT00',
              userAgentPackageName: 'app.dawarich',
              maxNativeZoom: 19,
            ),
            PolylineLayer(polylines: [
              Polyline(points: _points, strokeWidth: 4.0, color: Colors.blue, borderStrokeWidth: 2.0, borderColor: const Color(0xFF395078))
            ]),
            CurrentLocationLayer(),

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
