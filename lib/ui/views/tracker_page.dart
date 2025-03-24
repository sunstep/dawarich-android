import 'dart:ui';

import 'package:dawarich/main.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/dynamic_truncated_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
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
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lastPointCard(context, viewModel),
            const SizedBox(height: 12),
            const Divider(height: 32),
            _trackerConfigurations(context, viewModel),
          ],
        ),
      ),
    );
  }

  void _displayPopup(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Close the dialog
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }


  Widget _lastPointCard(BuildContext context, TrackerPageViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title and eye icon (unblurred)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Last Point Information",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      viewModel.hideLastPoint ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    tooltip: viewModel.hideLastPoint ? "Show Details" : "Hide Details",
                    onPressed: () {
                      viewModel.setHideLastPoint(!viewModel.hideLastPoint);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Details section wrapped in a Stack to apply blur if needed.
              Stack(
                children: [
                  // This container holds the key-value rows.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _keyValueRow("Timestamp:", viewModel.lastPoint?.formattedTimestamp ?? "No Data"),
                      const SizedBox(height: 4),
                      _keyValueRow("Longitude:", viewModel.lastPoint?.longitude.toString() ?? "No Data"),
                      const SizedBox(height: 4),
                      _keyValueRow("Latitude:", viewModel.lastPoint?.latitude.toString() ?? "No Data"),
                      const SizedBox(height: 4),
                      _keyValueRow("Points in batch:", viewModel.batchPointCount.toString()),
                    ],
                  ),
                  // Only overlay a blur if _lastPointBlur is true.
                  if (viewModel.hideLastPoint)
                    Positioned.fill(
                      child: ClipRect( // Ensure the blur doesn't bleed outside
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Buttons row (unblurred)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: viewModel.isTracking
                            ? null
                            : () async {
                          Result<void, String> result = await viewModel.trackPoint();
                          if (result case Err(value: String error)) {
                            _displayPopup("Tracking failed", error);
                          }
                        },
                        child: viewModel.isTracking
                            ? const CircularProgressIndicator()
                            : Text(
                              "Track point",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/batchExplorer");
                        },
                        child: Text(
                          "View Batch",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      child: viewModel.isRetrievingSettings? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with a toggle button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  viewModel.pageTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: viewModel.nextPage,
                  child: Text(viewModel.toggleButtonText),
                  
                ),
              ],
            ),
            const Divider(),
            if (viewModel.currentPage == 0)
              ..._recordingCard(context, viewModel)
            else if (viewModel.currentPage == 1)
              ..._basicSettings(context, viewModel)
            else if (viewModel.currentPage == 2)
                ..._advancedSettings(context, viewModel),
          ],
        ),
      ),
    );
  }

  List<Widget> _recordingCard(BuildContext context, TrackerPageViewModel viewModel) {
    return [
      // Status header
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            viewModel.isRecording ? "Recording in Progress" : "Not Recording",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Additional information only when recording.
      if (viewModel.isRecording) ...[
          DynamicTruncatedTooltip(text: "Track Id: ${viewModel.currentTrack!.trackId}")
        // const SizedBox(height: 4),
        // _keyValueRow("Points Recorded:", viewModel.trackPointCount.toString()),
        // const SizedBox(height: 4),
        // _keyValueRow("Tracking Duration:", viewModel.recordDuration),
        // Optionally, you can add more information such as average speed, battery info, etc.
      ],
      const SizedBox(height: 16),
      // Toggle recording button.
      Center(
        child: ElevatedButton(
          onPressed: viewModel.toggleRecording,
          child: Text(viewModel.isRecording ? "Stop Recording" : "Start Recording"),
        ),
      ),
    ];
  }

  List<Widget> _basicSettings(BuildContext context, TrackerPageViewModel viewModel) {
    return [
      // Automatic Tracking switch
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Automatic Tracking"),
          Switch(
            value: viewModel.isTrackingAutomatically,
            onChanged: viewModel.toggleAutomaticTracking,
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Points Per Batch slider
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
            onChanged: (value) => viewModel.setMaxPointsPerBatch(value.toInt()),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Tracking Frequency slider
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
            onChanged: (value) => viewModel.setTrackingFrequency(value.toInt()),
          ),
        ],
      ),
      const SizedBox(height: 16),

    ];
  }

  List<Widget> _advancedSettings(BuildContext context, TrackerPageViewModel viewModel) {
    return [
      // Location Tracking Accuracy dropdown
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Minimum Distance Between Points (m)"),
          Slider(
            value: viewModel.minimumPointDistance.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: "${viewModel.minimumPointDistance} m",
            onChanged: (value) => viewModel.setMinimumPointDistance(value.toInt()),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Tracker ID input field with tooltip for additional context
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Tracker ID"),
              const SizedBox(width: 4),
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: "The Tracker ID identifies your device when uploading points. If left empty, your device model will be used.",
                showDuration: Duration(seconds:5),
                child: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          TextField(
            controller: viewModel.trackerIdController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: "Reset to device model",
                onPressed: () {
                  viewModel.resetTrackerId();
                },
              ),
            ),
            onChanged: viewModel.setTrackerId,
          ),
        ],
      ),
    ];
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

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _viewModel.persistPreferences();
    }

    if (state == AppLifecycleState.resumed) {
      _viewModel.getLastPoint();
      _viewModel.getPointInBatchCount();
    }
  }


  @override
  void didPop() {
    _viewModel.persistPreferences();
    super.didPop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _viewModel.persistPreferences();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }


}
