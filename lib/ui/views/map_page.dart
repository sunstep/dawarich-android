import 'package:dawarich/ui/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:dawarich/ui/models/map_page_viewmodel.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {

  const MapPage({super.key});

  Widget _bottomsheetContent(
      BuildContext context, MapViewModel mapModel, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top draggable handle
          Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            height: 5.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Row(
                  children: [
                    // Previous day button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () async {
                        await mapModel.loadPreviousDay();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            _datePicker(context, mapModel);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            backgroundColor: Colors.transparent,
                            foregroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mapModel.displayDate(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!mapModel.isTodaySelected())
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          mapModel.loadNextDay();
                        },
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.2),
                        Colors.grey.withOpacity(0.6),
                        Colors.grey.withOpacity(0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Loading indicator or other bottom sheet content
                mapModel.isLoading ? const CustomLoadingIndicator(message: "Loading your timeline...") : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomSheet(MapViewModel mapModel) {

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.75,
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
      return const CustomLoadingIndicator(message: "Preparing the map...");
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
            PolylineLayer(
              polylines: [
                Polyline(
                  points: mapModel.points,
                  strokeWidth: 6.0, // Thicker for better visibility
                  color: Colors.blue.withOpacity(0.8),
                  borderStrokeWidth: 2.0, // Adds a subtle border for contrast
                  borderColor: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
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
    final mapViewModel = getIt<MapViewModel>();
    return ChangeNotifierProvider.value(
      value: mapViewModel,
      child: Builder(
        builder: (context) {
          return _pageBase(context);
        },
      ),
    );
  }

}
