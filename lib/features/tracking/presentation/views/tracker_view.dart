import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/di/providers/viewmodel_providers.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/tracking/domain/enum/location_precision.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:option_result/option_result.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
final class TrackerView extends ConsumerWidget {
  const TrackerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(trackerPageViewModelProvider);

    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: vmAsync.when(
        loading: () => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppbar(
            title: 'Tracker',
            titleFontSize: 32,
            backgroundColor: Colors.transparent,
          ),
          drawer: CustomDrawer(),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppbar(
            title: 'Tracker',
            titleFontSize: 32,
            backgroundColor: Colors.transparent,
          ),
          drawer: CustomDrawer(),
          body: Center(child: Text(e.toString())),
        ),
        data: (vm) {
          return ChangeNotifierProvider.value(
            value: vm,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: const CustomAppbar(
                title: 'Tracker',
                titleFontSize: 32,
                backgroundColor: Colors.transparent,
              ),
              drawer: CustomDrawer(),
              body: _TrackerViewContentBody(),
            ),
          );
        },
      ),
    );
  }
}

/// Everything below expects to read the VM via provider's `context.watch`.
/// This widget is the original tracker page content entry-point.
final class _TrackerViewContentBody extends StatefulWidget {
  @override
  State<_TrackerViewContentBody> createState() => _TrackerViewContentBodyState();
}

class _TrackerViewContentBodyState extends State<_TrackerViewContentBody> {
  StreamSubscription<String>? _consentSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to consent prompt stream (only once)
    _consentSub ??= context.read<TrackerPageViewModel>().onConsentPrompt.listen((message) {
      if (!mounted) return;
      _showConsentDialog(message);
    });
  }

  @override
  void dispose() {
    _consentSub?.cancel();
    super.dispose();
  }

  void _showConsentDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TrackerPageViewModel>().handleConsentResponse(false);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TrackerPageViewModel>().handleConsentResponse(true);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: const [
            LastPointCard(),
            _SettingsCard(),
          ],
        ),
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
                            onPressed: vm.isTracking
                                ? null
                                : () async {
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
                            onPressed: () => context.router.root
                                .push(const BatchExplorerRoute()),
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

  Future<void> handleManualPointRequest(
      BuildContext context, TrackerPageViewModel vm) async {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: TextFormField(
                key: const ValueKey('maxPointsPerBatchField'),
                initialValue: vm.maxPointsPerBatch.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  filled: false,
                  hintText: '${vm.minBatch}–${vm.maxBatch}',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
                onChanged: (value) {
                  final n = int.tryParse(value);
                  if (n != null) {
                    vm.setMaxPointsPerBatch(n.clamp(vm.minBatch, vm.maxBatch));
                  }
                },
                onEditingComplete: () {
                  vm.setMaxPointsPerBatch(
                      vm.maxPointsPerBatch.clamp(vm.minBatch, vm.maxBatch));
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null) return 'Enter a number';
                  if (n < vm.minBatch || n > vm.maxBatch) {
                    return '${vm.minBatch}–${vm.maxBatch} only';
                  }
                  return null;
                },
              ),
            ),
          ],
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
        Row(
          children: [
            Expanded(
              child: Slider(
                value: vm.trackingFrequency.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: '${vm.trackingFrequency}s',
                onChanged: (v) => vm.setTrackingFrequency(v.toInt()),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              child: Text(
                '${vm.trackingFrequency}s',
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
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
        DropdownButton<LocationPrecision>(
          value: vm.locationAccuracy,
          onChanged: (v) => v != null ? vm.setLocationAccuracy(v) : null,
          items: vm.accuracyOptions.map((opt) {
            return DropdownMenuItem(
              value: opt['value'] as LocationPrecision,
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
