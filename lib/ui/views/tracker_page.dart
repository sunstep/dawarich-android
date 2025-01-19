import 'package:flutter/material.dart';
import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:provider/provider.dart';

class TrackerPage extends StatelessWidget {

  const TrackerPage({super.key});

  Widget _pageContent(BuildContext context) {
    TrackerPageViewModel viewModel = context.watch<TrackerPageViewModel>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lastPointInformation(context, viewModel),

          Center(
            child: ElevatedButton(
              onPressed: () async {
                await viewModel.trackPoint();
              },
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text(
                  "Track Point",
              ),

            ),
          ),

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
              Text(
                "Last Point Information",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),

              _keyValueRow("Timestamp:", viewModel.lastPoint?.timestamp ?? "No Data"),
              const SizedBox(height: 4),
              _keyValueRow("Latitude:", viewModel.lastPoint?.latitude.toString() ?? "No Data"),
              const SizedBox(height: 4),
              _keyValueRow("Longitude:", viewModel.lastPoint?.longitude.toString() ?? "No Data"),
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
                  onChanged: viewModel.toggleTracking,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Points Per Batch"),
                Slider(
                  value: viewModel.pointsPerBatch.toDouble(),
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: "${viewModel.pointsPerBatch}",
                  onChanged: (value) =>
                      viewModel.setPointsPerBatch(value.toInt()),
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
                const Text("Location Accuracy (meters)"),
                Slider(
                  value: viewModel.desiredAccuracyMeters.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: "${viewModel.locationAccuracy} m",
                  onChanged: (value) =>
                      viewModel.setLocationAccuracy(value.toInt()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageBase(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Tracker", fontSize: 40),
      body: _pageContent(context),
      drawer: const CustomDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    TrackerPageViewModel viewModel = getIt<TrackerPageViewModel>();
    return ChangeNotifierProvider.value(value:
      viewModel,
      child: Builder(
        builder: (context) => _pageBase(context)
      ),
    );
  }

}