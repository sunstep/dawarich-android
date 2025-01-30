import 'package:dawarich/main.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class TrackerPage extends StatefulWidget {

  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => TrackerPageState();
}

class TrackerPageState extends State<TrackerPage> with WidgetsBindingObserver, RouteAware {

  late TrackerPageViewModel _viewModel;

  Widget _pageContent(BuildContext context) {
    TrackerPageViewModel viewModel = context.watch<TrackerPageViewModel>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lastPointInformation(context, viewModel),
          const SizedBox(height: 12),

          const Divider(height: 32),

          Expanded(
            child: _trackerConfigurations(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _lastPointInformation(BuildContext context, TrackerPageViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Last Point Information",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 8),

              _keyValueRow("Timestamp:", viewModel.lastPoint?.timestamp ?? "No Data"),
              const SizedBox(height: 4),
              _keyValueRow("Longitude:", viewModel.lastPoint?.longitude.toString() ?? "No Data"),
              const SizedBox(height: 4),
              _keyValueRow("Latitude:", viewModel.lastPoint?.latitude.toString() ?? "No Data"),
              const SizedBox(height: 4),
              _keyValueRow("Points in batch:", viewModel.batchPointCount.toString()),

              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly distributes buttons
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await viewModel.trackPoint();
                        },
                        child: const Text("Track point"),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/batchExplorer");
                        },
                        child: const Text("View Batch"),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyValueRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _trackerConfigurations(BuildContext context, TrackerPageViewModel viewModel) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Automatic Tracking"),
                Switch(
                  value: viewModel.isTrackingEnabled,
                  onChanged: viewModel.toggleAutomaticTracking,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Points Per Batch"),
                Slider(
                  value: viewModel.maxPointsPerBatch.toDouble(),
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: "${viewModel.maxPointsPerBatch}",
                  onChanged: (value) =>
                      viewModel.setMaxPointsPerBatch(value.toInt()),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tracking Frequency (seconds)"),
                Slider(
                  value: viewModel.trackingFrequency.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: "${viewModel.trackingFrequency} s",
                  onChanged: (value) =>
                      viewModel.setTrackingFrequency(value.toInt()),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Location tracking accuracy"),
                const SizedBox(height: 8),
                DropdownButton<LocationAccuracy>(
                  value: viewModel.locationAccuracy,
                  onChanged: (LocationAccuracy? newValue) {
                    if (newValue != null) {
                      viewModel.setLocationAccuracy(newValue);
                    }
                  },
                  items: viewModel.accuracyOptions.map((option) {
                    return DropdownMenuItem<LocationAccuracy>(
                      value: option['value'] as LocationAccuracy,
                      child: Text(option['label'] as String),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),



          ],
        ),
      ),
    );
  }

  Widget _pageBase(BuildContext context, TrackerPageViewModel viewModel) {
    return Scaffold(
      appBar: const Appbar(title: "Tracker", fontSize: 40),
      body: _pageContent(context),
      drawer: const CustomDrawer(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = getIt<TrackerPageViewModel>();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TrackerPageViewModel>(
        builder: (context, vm, child) => _pageBase(context, vm)
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.initialize();
    }
  }

  @override
  void didPopNext() {
    _viewModel.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }


}
