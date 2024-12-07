import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:dawarich/ui/models/map_page_viewmodel.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {

  const MapPage({super.key});

  Widget _bottomsheetContent(BuildContext context, MapViewModel mapModel, ScrollController scrollController) {
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
                        mapModel.loadPreviousDay;
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            _datePicker(context, mapModel);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mapModel.displayDate(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          )
                        ),
                      ),
                    ),
                    if (!mapModel.isTodaySelected())
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          mapModel.loadNextDay;
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
                mapModel.isLoading? const Center(child: CircularProgressIndicator(color: Colors.cyan)) : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(MapViewModel mapModel) {

    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.11,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return _bottomsheetContent(context, mapModel, scrollController);
      },
    );
  }

  Future<void> _datePicker(BuildContext context, MapViewModel mapModel) async {

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: mapModel.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      await mapModel.processNewDate(pickedDate);
    }

  }

  Widget _pageContent(MapViewModel mapModel) {

    if (mapModel.currentLocation == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: mapModel.currentLocation!,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=NWn5VTZI9avXmOoeAT00',
              userAgentPackageName: 'app.dawarich',
              maxNativeZoom: 19,
            ),
            PolylineLayer(polylines: [
              Polyline(points: mapModel.points, strokeWidth: 4.0, color: Colors.blue, borderStrokeWidth: 2.0, borderColor: const Color(0xFF395078))
            ]),
            CurrentLocationLayer(),
          ],
        ),
        _buildBottomSheet(mapModel)
      ],
    );
  }

  Widget _pageBase(BuildContext context) {
    MapViewModel viewModel = context.watch<MapViewModel>();
    return Scaffold(
      appBar: const Appbar(title: "Timeline", fontSize: 20),
      body: _pageContent(viewModel),
      drawer: const CustomDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeMapViewModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyan));
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load: ${snapshot.error}'));
        }

        // Once initialized, provide the viewModel
        return ChangeNotifierProvider(
          create: (_) => getIt<MapViewModel>(),
          child: Builder(builder: (context) => _pageBase(context)),
        );
      },
    );
  }

  Future<void> _initializeMapViewModel() async {
    final viewModel = getIt<MapViewModel>();
    await viewModel.initialize(); // Await the async initialization
  }
}
