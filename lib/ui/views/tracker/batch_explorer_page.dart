import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/models/local/batch_explorer_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';
import 'package:dawarich/ui/theme/app_gradients.dart';
import 'package:dawarich/ui/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final class BatchExplorerPage extends StatelessWidget {
  const BatchExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<BatchExplorerViewModel>();

    return ChangeNotifierProvider.value(
      value: viewModel,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppbar(
                title: "Batch Explorer",
                titleFontSize: 30,
                backgroundColor: Colors.transparent),
            body: SafeArea(child: _BatchContent()),
            bottomNavigationBar: Consumer<BatchExplorerViewModel>(
              builder: (context, vm, _) {
                return vm.hasPoints
                    ? const _BatchFooter()
                    : const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

class _BatchContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BatchExplorerViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            vm.hasPoints
                ? '${vm.batch.points.length} Point${vm.batch.points.length > 1 ? 's' : ''}'
                : 'No points in batch',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: vm.isLoadingPoints
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: vm.batch.points.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final pt = vm.batch.points[i];
                      return _PointCard(
                        timestamp: pt.properties.formattedTimestamp,
                        latitude: pt.geometry.coordinates[1],
                        longitude: pt.geometry.coordinates[0],
                        onDelete: () =>
                            _Dialogs.confirmDeletePoint(context, vm, pt),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 80), // leave room for footer
        ],
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final String timestamp;
  final double latitude, longitude;
  final VoidCallback onDelete;
  const _PointCard({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timestamp,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Lat: $latitude, Lon: $longitude',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.redAccent,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchFooter extends StatelessWidget {
  const _BatchFooter();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BatchExplorerViewModel>();
    if (!vm.hasPoints) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete All'),
                  onPressed: () => _Dialogs.confirmClearBatch(context, vm),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload Batch'),
                  onPressed: () => _Dialogs.confirmUploadBatch(context, vm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class _Dialogs {
  static void confirmDeletePoint(
    BuildContext c,
    BatchExplorerViewModel vm,
    LocalPointViewModel pt,
  ) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text("Delete Point"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              vm.deletePoint(pt);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void confirmClearBatch(BuildContext c, BatchExplorerViewModel vm) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text("Clear Batch"),
        content: const Text("Delete all points? This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              vm.clearBatch();
            },
            child:
                const Text("Delete All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void confirmUploadBatch(BuildContext c, BatchExplorerViewModel vm) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text("Upload Batch"),
        content: const Text("Ready to upload this batch?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              vm.uploadBatch();
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }
}
