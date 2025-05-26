import 'dart:async';
import 'dart:io';
import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/main.dart';
import 'package:dawarich/ui/theme/theme_extensions.dart';
import 'package:dawarich/ui/widgets/custom_appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

final class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

final class _TrackerPageState extends State<TrackerPage> with WidgetsBindingObserver, RouteAware {
  late final TrackerPageViewModel _viewModel;
  late final StreamSubscription<void> _settingsSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _viewModel = getIt<TrackerPageViewModel>();
    _viewModel.initialize();

    // delay the actual showDialog until after build()
    _settingsSub = _viewModel.onSystemSettingsPrompt.listen((_) {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final open = await _showSystemSettingsConfirmation(context);
        if (open) {
          await _viewModel.openSystemSettings();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _settingsSub.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
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

  Future<bool> _showSystemSettingsConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Background Tracking Needs Your Help'),
        content: Text(
          Platform.isAndroid
              ? 'To keep tracking running in the background, disable battery optimization for this app.'
              : 'To keep tracking running in the background, grant “Always” location permission in Settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Later')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open Settings')),
        ],
      ),
    ).then((v) => v ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Container(
        // full-screen diagonal gradient from our theme extension
        decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppbar(
            title: 'Tracker',
            titleFontSize: 32,
            backgroundColor: Colors.transparent,
          ),
          drawer: CustomDrawer(),
          body: SafeArea(child: _TrackerBody()),
        ),
      ),
    );
  }
}

class _TrackerBody extends StatelessWidget {
  const _TrackerBody();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LastPointCard(),
          SizedBox(height: 32),
          _SettingsCard(),
        ],
      ),
    );
  }
}

class LastPointCard extends StatelessWidget {
  const LastPointCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<TrackerPageViewModel>();
    final accent = Theme.of(context).colorScheme.secondary;
    const white  = Colors.white;
    const white70= Colors.white70;

    final isExpanded = !vm.hideLastPoint;

    // helper for each info row
    Widget tile(IconData icon, String label, String value) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: white),
        title: Text(label, style: const TextStyle(color: white70)),
        trailing: Text(value,
            style: const TextStyle(color: white, fontWeight: FontWeight.bold)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        color: Colors.black,
        elevation: 16,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // — Header with tap to expand/collapse —
            InkWell(
              onTap: () => vm.setHideLastPoint(!vm.hideLastPoint),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Last Point',
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(color: white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: white70,
                    ),
                  ],
                ),
              ),
            ),

            // — Animated body —
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 16),

                    // info rows
                    tile(
                      Icons.access_time,
                      'Time',
                      vm.lastPoint?.formattedTimestamp ?? '—',
                    ),
                    tile(
                      Icons.format_list_numbered,
                      'Batch Size',
                      vm.batchPointCount.toString(),
                    ),
                    tile(
                      Icons.my_location,
                      'Latitude',
                      vm
                          .lastPoint
                          ?.latitude
                          .toStringAsFixed(5) ??
                          '—',
                    ),
                    tile(
                      Icons.my_location,
                      'Longitude',
                      vm
                          .lastPoint
                          ?.longitude
                          .toStringAsFixed(5) ??
                          '—',
                    ),

                    const SizedBox(height: 24),

                    // action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: accent),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: vm.isTracking
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                                : Icon(Icons.add_location_alt,
                                color: accent),
                            label: const Text('Track Point',
                                style: TextStyle(color: white)),
                            onPressed:
                            vm.isTracking ? null : vm.trackPoint,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.view_list),
                            label: const Text('View Batch'),
                            onPressed: () => Navigator.pushNamed(
                                context, '/batchExplorer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
/// A little “info tile” with an icon + multi-line value.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> valueLines;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.valueLines,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!;
    final grey = Colors.grey[600]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: style.copyWith(color: grey)),
              const SizedBox(height: 4),
              // each line (Date / time broken out) is right-aligned so the numbers line up
              ...valueLines.map((line) => Align(
                alignment: Alignment.centerRight,
                child: Text(
                  line,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrackerPageViewModel>();
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ——— UNIFIED HEADER ———
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  vm.pageTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: vm.nextPage,
                    child: Text(vm.toggleButtonText),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white54),
              ],
            ),

            const SizedBox(height: 16),

            // ——— BODY CONTENT ———
            if (vm.currentPage == 0) ...[
              _RecordingSection(),
            ] else if (vm.currentPage == 1) ...[
              _BasicSettingsSection(),
            ] else ...[
              _AdvancedSettingsSection(),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrackerPageViewModel>();
    return Column(
      children: [
        Text(
          vm.isRecording ? 'Recording in Progress' : 'Not Recording',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        if (vm.isRecording)
          Text('Track ID: ${vm.currentTrackId}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: vm.isRecording ? Colors.redAccent : Colors.greenAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: vm.toggleRecording,
          child: Text(vm.isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ],
    );
  }
}

class _BasicSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrackerPageViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('Automatic Tracking'),
          value: vm.isTrackingAutomatically,
          onChanged: vm.toggleAutomaticTracking,
        ),
        const SizedBox(height: 16),
        Text('Points per batch: ${vm.maxPointsPerBatch}'),
        Slider(
          value: vm.maxPointsPerBatch.toDouble(),
          min: 50,
          max: 1000,
          divisions: 19,
          onChanged: (v) => vm.setMaxPointsPerBatch(v.toInt()),
        ),
        const SizedBox(height: 16),
        Text('Tracking frequency: ${vm.trackingFrequency}s'),
        Slider(
          value: vm.trackingFrequency.toDouble(),
          min: 5,
          max: 60,
          divisions: 11,
          onChanged: (v) => vm.setTrackingFrequency(v.toInt()),
        ),
      ],
    );
  }
}

class _AdvancedSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrackerPageViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Location accuracy'),
        DropdownButton<LocationAccuracy>(
          value: vm.locationAccuracy,
          onChanged: (v) => v != null ? vm.setLocationAccuracy(v) : null,
          items: vm.accuracyOptions.map((opt) {
            return DropdownMenuItem(
              value: opt['value'] as LocationAccuracy,
              child: Text(opt['label'] as String),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Minimum distance (m): ${vm.minimumPointDistance}'),
        Slider(
          value: vm.minimumPointDistance.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (v) => vm.setMinimumPointDistance(v.toInt()),
        ),
        const SizedBox(height: 24),
        const Text('Device ID'),
        TextField(
          controller: vm.trackerIdController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: vm.resetTrackerId,
            ),
          ),
          onChanged: vm.setTrackerId,
        ),
      ],
    );
  }
}