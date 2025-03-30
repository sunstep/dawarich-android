import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/models/local/batch_explorer_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';
import 'package:dawarich/ui/widgets/appbars/batch_explorer_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BatchExplorerPage extends StatelessWidget{

  const BatchExplorerPage({super.key});

  Widget _pageContent(BuildContext context) {
    BatchExplorerViewModel viewModel = context.watch<BatchExplorerViewModel>();
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.hasPoints)
          Center(
            child: Text(
              "${viewModel.batch.points.length} Points",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          const SizedBox(height: 12),

          // List of Points with Loading Indicator
          Expanded(
            child: viewModel.isLoadingPoints
                ? const Center(child: CircularProgressIndicator())
                : !viewModel.hasPoints
                ? const Center(child: Text("No points in batch"))
                : ListView.builder(
              itemCount: viewModel.batch.points.length,
              itemBuilder: (context, index) {
                final point = viewModel.batch.points[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      point.properties.formattedTimestamp,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Lat: ${point.geometry.coordinates[1]}, Lon: ${point.geometry.coordinates[0]}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeletePoint(context, viewModel, point),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Delete All Points Button
          if (!viewModel.isLoadingPoints && viewModel.hasPoints)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures buttons are evenly spaced
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _confirmClearBatch(context, viewModel),
                  child: const Text("Delete All Points"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _confirmUploadBatch(context, viewModel),
                  child: const Text("Upload Batch"),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmDeletePoint(BuildContext context, BatchExplorerViewModel viewModel, LocalPointViewModel point) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Delete Point"),
          content: const Text("Are you sure you want to delete this point? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Close the dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close the dialog
                viewModel.deletePoint(point);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// **Show confirmation dialog before clearing all points**
  void _confirmClearBatch(BuildContext context, BatchExplorerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Clear Batch"),
          content: const Text("Are you sure you want to delete all points? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Close the dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close the dialog
                viewModel.clearBatch();
              },
              child: const Text("Delete All", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _confirmUploadBatch(BuildContext context, BatchExplorerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Upload batch"),
          content: const Text("Are you sure you want to upload the batch?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                viewModel.uploadBatch();
              },
              child: const Text("Upload")
            )
          ],
        );
      });
  }

  Widget _pageBase(BuildContext context) {
    return Scaffold(
      appBar: const BatchExplorerAppbar(),
      body: _pageContent(context)
    );
  }

  @override
  Widget build(BuildContext context) {
    BatchExplorerViewModel viewModel = getIt<BatchExplorerViewModel>();

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Builder(
          builder: (context) => _pageBase(context)
      ),
    );
  }

}