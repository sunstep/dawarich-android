import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/main.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:provider/provider.dart';

@RoutePage()
final class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => getIt<TrackerPageViewModel>()..initialize(),
        builder: (context, child) => Consumer<TrackerPageViewModel>(
            builder: (context, vm, child) => _TrackerPageContent()
        )
    );
  }
}

final class _TrackerPageContent extends StatefulWidget {

  @override
  State<_TrackerPageContent> createState() => _TrackerPageContentState();
}

final class _TrackerPageContentState extends State<_TrackerPageContent> with
    WidgetsBindingObserver, RouteAware {

  StreamSubscription<String>? _consentPromptSub;
  _TrackerPageContentState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TrackerPageViewModel vm = context.read<TrackerPageViewModel>();
    return buildTrackerPage(context, vm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final route = ModalRoute.of(context);
      if (route != null) {
        routeObserver.subscribe(this, route);
      }
    });

    if (_consentPromptSub == null) {
      Future.microtask(() {
        if (!mounted) return;

        final vm = context.read<TrackerPageViewModel>();
        _consentPromptSub = vm.onConsentPrompt.listen((message) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) return;

            final result = await showDialog<bool>(
              context: context,
              barrierDismissible: true,
              builder: (ctx) => AlertDialog(
                title: const Text('Dawarich Needs Permission'),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('No thanks'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );

            vm.handleConsentResponse(result ?? false);
          });
        });
      });
    }
  }
  @override
  void didPushNext() {
    _consentPromptSub?.cancel();
    _consentPromptSub = null;

    Future.microtask(() {
      try {

        final BuildContext localContext = context;

        if (localContext.mounted) {
          final viewModel = localContext.read<TrackerPageViewModel>();
          viewModel.persistPreferences();
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint("Error persisting preferences on didPushNext: $error");
        }
      }
    });
  }

  @override
  void didPopNext() {
    _consentPromptSub?.cancel();
    _consentPromptSub = null;

    Future.microtask(() {
      try {

        final BuildContext localContext = context;

        if (localContext.mounted) {
          final viewModel = localContext.read<TrackerPageViewModel>();
          viewModel.getLastPoint();
          viewModel.getPointInBatchCount();
        }

      } catch (error) {
        if (kDebugMode) {
          debugPrint("Error fetching last point on didPopNext: $error");
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Future.microtask(() {
      try {

        final BuildContext localContext = context;

        if (localContext.mounted) {
          final viewModel = localContext.read<TrackerPageViewModel>();

          if (state == AppLifecycleState.paused ||
              state == AppLifecycleState.inactive) {
            viewModel.persistPreferences();
          }
          if (state == AppLifecycleState.resumed) {
            viewModel.getLastPoint();
            viewModel.getPointInBatchCount();
          }
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint("Error handling app lifecycle state change: $error");
        }
      }
    });
  }


  Widget buildTrackerPage(BuildContext context, TrackerPageViewModel vm) {

    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppbar(
          title: 'Tracker',
          titleFontSize: 32,
          backgroundColor: Colors.transparent,
        ),
        drawer: CustomDrawer(),
        body: SafeArea(child: _TrackerBody()),
      ),
    );
  }
}

class _TrackerBody extends StatelessWidget {

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
    final vm = context.watch<TrackerPageViewModel>();
    final accent = Theme.of(context).colorScheme.secondary;
    final theme = Theme.of(context);
    final white = theme.colorScheme.onSurface;
    final white70 = white.withValues(alpha: 0.7);

    final isExpanded = !vm.hideLastPoint;

    // helper for each info row
    Widget tile(IconData icon, String label, String value) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: white),
        title: Text(label, style: TextStyle(color: white70)),
        trailing: Text(value,
            style: TextStyle(color: white, fontWeight: FontWeight.bold)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // — Header with tap to expand/collapse —
            InkWell(
              onTap: () => vm.setHideLastPoint(!vm.hideLastPoint),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: Text(
                        'Last Point',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                                color: white, fontWeight: FontWeight.bold),
                      )),
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
                    Divider(color: Theme.of(context).dividerColor),
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
                      vm.lastPoint?.latitude.toStringAsFixed(5) ?? '—',
                    ),
                    tile(
                      Icons.my_location,
                      'Longitude',
                      vm.lastPoint?.longitude.toStringAsFixed(5) ?? '—',
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
                                : Icon(Icons.add_location_alt, color: accent),
                            label: Text('Track Point',
                                style: TextStyle(color: white)),
                            onPressed: vm.isTracking ? null : () async {
                              await handleManualPointRequest(context, vm);
                            },
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
                            onPressed: () => context.router.root.push(const BatchExplorerRoute()),
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

  Future<void> handleManualPointRequest(BuildContext context, TrackerPageViewModel vm) async {

    if (vm.isTrackingAutomatically) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Manual Tracking Disabled'),
          content: const Text(
            'Manual tracking is disabled while automatic tracking is active. '
                'Please stop automatic tracking first if you want to manually add a point.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await vm.trackPoint();
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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      initialIndex: vm.currentPage,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // ——— Tab Navigation Header ———
              TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium!.color,
                indicatorColor: theme.colorScheme.primary,
                onTap: vm.setCurrentPage,
                tabs: const [
                  Tab(text: 'Recording'),
                  Tab(text: 'Basic'),
                  Tab(text: 'Advanced'),
                ],
              ),
              const SizedBox(height: 16),

              // ——— Tab Content ———
              SizedBox(
                height: 400, // You can make this dynamic or wrap content
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _RecordingSection(),
                    _BasicSettingsSection(),
                    _AdvancedSettingsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrackerPageViewModel>();
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          vm.isRecording ? 'Recording in Progress' : 'Not Recording',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        if (vm.isRecording)
          Text('Track ID: ${vm.currentTrack?.trackId}',
              style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: vm.isRecording
                ? theme.colorScheme.error.withValues(alpha: 0.85)
                : theme.colorScheme.secondary.withValues(alpha: 0.85),
            foregroundColor: theme.colorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings_remote, size: 20),
            const SizedBox(width: 8),
            Text(
              'General',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Automatic Tracking'),
          value: vm.isTrackingAutomatically,
          onChanged: (enabled) async {
            final result = await vm.toggleAutomaticTracking(enabled);
            if (!context.mounted) {
              return;
            }
            if (result case Err(value: final message)) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Tracking Setup Failed"),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.layers, size: 20),
            const SizedBox(width: 8),
            Text(
              'Batching',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Points per batch: ${vm.maxPointsPerBatch}'),
        Slider(
          value: vm.maxPointsPerBatch.toDouble(),
          min: 50,
          max: 1000,
          divisions: 19,
          label: '${vm.maxPointsPerBatch}',
          onChanged: (v) => vm.setMaxPointsPerBatch(v.toInt()),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.timer, size: 20),
            const SizedBox(width: 8),
            Text(
              'Frequency',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Tracking frequency: ${vm.trackingFrequency}s'),
        Slider(
          value: vm.trackingFrequency.toDouble(),
          min: 5,
          max: 60,
          divisions: 11,
          label: '${vm.trackingFrequency}s',
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.precision_manufacturing, size: 20),
            const SizedBox(width: 8),
            Text(
              'Accuracy',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
        Row(
          children: [
            const Icon(Icons.social_distance, size: 20),
            const SizedBox(width: 8),
            Text(
              'Distance Threshold',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Minimum distance (m): ${vm.minimumPointDistance}'),
        Slider(
          value: vm.minimumPointDistance.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '${vm.minimumPointDistance}m',
          onChanged: (v) => vm.setMinimumPointDistance(v.toInt()),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.perm_device_information, size: 20),
            const SizedBox(width: 8),
            Text(
              'Device ID',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: vm.deviceIdController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: vm.resetDeviceId,
              tooltip: 'Reset ID',
            ),
          ),
          onChanged: vm.setDeviceId,
        ),
      ],
    );
  }
}
