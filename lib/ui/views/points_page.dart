import 'package:dawarich/ui/models/api/v1/points/response/api_point_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:intl/intl.dart';
import 'package:dawarich/ui/models/local/points_page_viewmodel.dart';
import 'package:provider/provider.dart';

final class PointsPage extends StatelessWidget {

  const PointsPage({super.key});

  void _selectStartDate(BuildContext context, PointsPageViewModel viewModel) async {

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != viewModel.startDate) {
      viewModel.setStartDate(picked);
    }
  }

  void _selectEndDate(BuildContext context, PointsPageViewModel viewModel) async {

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.endDate,
      firstDate: DateTime(2000),
      lastDate: viewModel.endDate,
    );
    if (picked != null && picked != viewModel.endDate) {

      viewModel.setEndDate(picked);
    }
  }


  Future<void> _confirmDeletion(BuildContext context, PointsPageViewModel viewModel) async {
    showDialog(context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete selected points?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            }, child: const Text("Cancel")
          ),
          TextButton(
              onPressed: () {
                viewModel.deleteSelection();
                Navigator.of(context).pop(false);
              },
              child:
              const Text("Delete")
          ),
      ])
    );
  }

  Future<void> _confirmExport(BuildContext context) async {
    showDialog(context: context,
      builder: (context) => AlertDialog(
        title: const Text("This feature is not available yet."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            }, child: const Text("Dismiss")
          ),
        ]
      )
    );
  }

  Widget _pageContent(BuildContext context) {

    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final TextStyle? bodyMedium = Theme.of(context).textTheme.bodyMedium;
    final TextStyle? bodyLarge = Theme.of(context).textTheme.bodyLarge;

    PointsPageViewModel viewModel = context.watch<PointsPageViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartDate(context, viewModel),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Start at',
                        labelStyle: bodyLarge,
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                      ),
                      controller: TextEditingController(
                        text: '${viewModel.startDate.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndDate(context, viewModel),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'End at',
                        labelStyle: bodyLarge,
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      controller: TextEditingController(
                        text: '${viewModel.endDate.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  viewModel.searchPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  side: const BorderSide(
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Search',
                style: bodyLarge),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: viewModel.isLoading ? _buildSkeletonLoader() : _buildDataTable(context, viewModel),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (viewModel.hasSelectedItems())
                ElevatedButton(
                  onPressed: () {
                    _confirmDeletion(context, viewModel);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Delete Selected',
                    style: bodyMedium,
                  ),
              ),
              if (viewModel.hasSelectedItems())
                const SizedBox(width: 10),
              if (viewModel.hasSelectedItems())
                ElevatedButton(
                  onPressed: () {
                    _confirmExport(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder (
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                      "Export Selected",
                    style: bodyMedium,
                  ),
                ),
              Expanded(
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!viewModel.hasSelectedItems())
                      IconButton(
                        onPressed: viewModel.navigateFirst,
                        icon: const Icon(Icons.first_page),
                      ),
                    if (!viewModel.hasSelectedItems())
                      IconButton(
                        onPressed: viewModel.navigateBack,
                        icon: const Icon(Icons.navigate_before),
                      ),
                    if (!viewModel.hasSelectedItems())
                      Text("${viewModel.currentPage}/${viewModel.totalPages}"),
                    if (!viewModel.hasSelectedItems())
                      const SizedBox(width: 8),
                    if (!viewModel.hasSelectedItems())
                      IconButton(
                        onPressed: viewModel.navigateNext,
                        icon: const Icon(Icons.navigate_next),
                      ),
                    if (!viewModel.hasSelectedItems())
                      IconButton(
                        onPressed: viewModel.navigateLast,
                        icon: const Icon(Icons.last_page),
                      ),
                  ],
                ),
              ),
              if (!viewModel.hasSelectedItems())
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      viewModel.toggleSort();
                      viewModel.sortPoints();
                    },
                    child: Text(
                      viewModel.sortByNew ? 'Newest' : 'Oldest',
                      style: bodyMedium,
                    ),
                  ),
                ],
              ),
              if (viewModel.hasSelectedItems())
                Row(
                  children: [
                    Text(
                      "${viewModel.selectedItems.length}",
                      style: bodyMedium,
                    ),
                  ]
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Checkbox(
                value: false,
                onChanged: null,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.grey.shade300,
                      height: 20.0,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      color: Colors.grey.shade300,
                      height: 20.0,
                      width: 150.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                color: Colors.grey.shade300,
                height: 20.0,
                width: 50.0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context, PointsPageViewModel viewModel) {

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final checkColor = isDarkTheme? Colors.white : Colors.black;
    final borderColor = Theme.of(context).dividerColor;

    final bodyMedium = Theme.of(context).textTheme.bodyMedium;

    final DateFormat dateFormat = DateFormat('dd MMM yyyy, HH:mm:ss');

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 8,
          headingRowColor:
          WidgetStateColor.resolveWith((states) => backgroundColor),
          dataRowColor: WidgetStateColor.resolveWith((states) => backgroundColor),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Checkbox(
                  value: viewModel.selectAll,
                  onChanged: (value) => viewModel.toggleSelectAll(),
                  checkColor: checkColor,
                  activeColor: backgroundColor,
                  side: BorderSide(color: checkColor),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Recorded At',
                style: bodyMedium,
              ),
            ),
            DataColumn(
              label: Text(
                'Coordinates',
                style: bodyMedium,
              ),
            ),
          ],
          rows: List<DataRow>.generate(
            viewModel.pagePoints.length,
            (index) {
              final ApiPointViewModel point = viewModel.pagePoints[index];
              final int? recordedAt = point.timestamp;
              final String? latitude = point.latitude;
              final String? longitude = point.longitude;

              final DateTime parsedDate = DateTime.fromMillisecondsSinceEpoch(recordedAt!*1000);
              final String formattedDate = dateFormat.format(parsedDate);
              final isSelected = viewModel.selectedItems.contains(point.id.toString());

              return DataRow(
                cells: [
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => viewModel.toggleSelection(index, value),
                      side: BorderSide(color: checkColor),
                      //checkColor: ,
                      //activeColor: activeColor,
                    ),
                  ),
                  DataCell(
                    Text(
                      formattedDate,
                      style: bodyMedium,
                    ),
                  ),
                  DataCell(
                    Text(
                      '$latitude, $longitude',
                      style: bodyMedium,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      )
    );
  }

  Widget _pageBase(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Points", fontSize: 40),
      body: _pageContent(context),
      drawer: const CustomDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {

    PointsPageViewModel viewModel = PointsPageViewModel();
    return ChangeNotifierProvider.value(value:
    viewModel,
      child: Builder(
        builder: (context) => _pageBase(context)
      ),
    );
  }

}