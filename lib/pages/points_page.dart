import 'package:dawarich/containers/point_page_container.dart';
import 'package:dawarich/models/api_point.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/widgets/drawer.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PointsPage extends StatefulWidget {

  const PointsPage({super.key});

  @override
  PointsPageState createState() => PointsPageState();
}

class PointsPageState extends State<PointsPage> {

  String? _endpoint;
  String? _apiKey;

  bool _isLoading = true;
  bool _selectAll = false;



  Set<String> _selectedItems = {};
  bool _sortByNew = true;

  final PointsPageContainer _container = PointsPageContainer();

  List<ApiPoint> _getCurrentPagePoints() {
    final int start = _container.currentPage * _container.pointsPerPage;
    final int end = start + _container.pointsPerPage;

    if (start >= _container.points.length) {
      return [];
    }

    return _container.points.sublist(start, end > _container.points.length ? _container.points.length : end);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    await _container.fetchEndpointInfo(context);
    await _container.fetchPoints(_container.pointsPerPage, _container.currentPage);
    _isLoading = false;
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _container.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _container.startDate) {
      setState(() {
        _container.startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _container.endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _container.endDate) {
      setState(() {
        _container.endDate = picked;
      });
    }
  }

  void _toggleSelectAll(bool? value) {

    setState(() {

      _selectAll = !_selectAll;

      if (value == true){
        _selectedItems = _getCurrentPagePoints().map((point) => point.id.toString()).toSet();
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _toggleSelection(int index, bool? value) {

    final String pointId = _container.points[index].id.toString();

    setState(() {

      if (value == true){
        _selectedItems.add(pointId);
      } else {
        _selectedItems.remove(pointId);
      }

      _selectAll = _isAllSelected();
    });
  }

  void _toggleSort() {

    setState(() {
      _sortByNew = !_sortByNew;
    });
  }

  void _sortPoints(){

    setState(() {

      if (_sortByNew) {
        _container.points.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt!);
          DateTime dateB = DateTime.parse(b.createdAt!);
          return dateB.compareTo(dateA);
        });
      } else {
        _container.points.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt!);
          DateTime dateB = DateTime.parse(b.createdAt!);
          return dateA.compareTo(dateB);
        });
      }
    });
  }

  bool hasSelectedItems() => _selectedItems.isNotEmpty;

  bool _isAllSelected() => _selectedItems.length == _container.pointsPerPage;

  Future<void> _searchPressed() async {
    setState(() {
      _isLoading = true;
      _container.points.clear();
      _container.currentPage = 0;

    });

    await _container.fetchPoints(_container.pointsPerPage, _container.currentPage);
  }


  Future<void> _deleteSelection() async {

    final selectedItemsCopy = _selectedItems.toList();

    for (String pointId in selectedItemsCopy){
      final uri = Uri.parse("$_endpoint/api/v1/points/$pointId?api_key=$_apiKey");
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        setState(() {
          _container.points.removeWhere((point) => point.id.toString() == pointId);
          _selectedItems.remove(pointId);
          _selectAll = _isAllSelected();
        });

      }
    }
  }

  Future<void> _confirmDeletion() async {
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
                _deleteSelection();
                Navigator.of(context).pop(false);
              },
              child:
              const Text("Delete")
          ),
      ])
    );
  }

  Future<void> _confirmExport() async {
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

  Widget _pageContent() {

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;


    final bodyMedium = Theme.of(context).textTheme.bodyMedium;
    final bodyLarge = Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartDate(context),
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
                        text: '${_container.startDate.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndDate(context),
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
                        text: '${_container.endDate.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchPressed();
                  });
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
            child: _isLoading ? _buildSkeletonLoader() : _buildDataTable(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasSelectedItems())
                ElevatedButton(
                  onPressed: () {
                    _confirmDeletion();
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
              if (hasSelectedItems())
                const SizedBox(width: 10),
              if (hasSelectedItems())
                ElevatedButton(
                  onPressed: () {
                    _confirmExport();
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
                    if (!hasSelectedItems())
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            if (_container.currentPage != 0){
                              _isLoading = true;
                              _container.currentPage = 0;
                            }

                            _container.fetchPoints(_container.pointsPerPage, _container.currentPage);
                          });
                        },
                        icon: const Icon(Icons.first_page),
                      ),
                    if (!hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_container.currentPage > 0){
                              _isLoading = true;
                              _container.currentPage--;
                            }

                            _container.fetchPoints(_container.pointsPerPage, _container.currentPage);
                          });
                        },
                        icon: const Icon(Icons.navigate_before),
                      ),
                    if (!hasSelectedItems())
                      Text("${_container.currentPage}/${_container.totalPages}"),
                    if (!hasSelectedItems())
                      const SizedBox(width: 8),
                    if (!hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_container.currentPage != _container.totalPages){
                              _isLoading = true;
                              _container.currentPage++;
                            }
                            _container.fetchPoints(_container.pointsPerPage, _container.currentPage);
                          });
                        },
                        icon: const Icon(Icons.navigate_next),
                      ),
                    if (!hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_container.currentPage < _container.totalPages){
                              _isLoading = true;
                              _container.currentPage = _container.totalPages;
                            }
                            _container.fetchPoints(_container.pointsPerPage, _container.currentPage);
                          });
                        },
                        icon: const Icon(Icons.last_page),
                      ),
                  ],
                ),
              ),
              if (!hasSelectedItems())
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _toggleSort();
                      _sortPoints();
                    },
                    child: Text(
                      _sortByNew ? 'Newest' : 'Oldest',
                      style: bodyMedium,
                    ),
                  ),
                ],
              ),
              if (hasSelectedItems())
                Row(
                  children: [
                    Text(
                      "${_selectedItems.length}",
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

  Widget _buildDataTable() {

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final checkColor = isDarkTheme? Colors.white : Colors.black;
    final borderColor = Theme.of(context).dividerColor;

    final bodyMedium = Theme.of(context).textTheme.bodyMedium;

    final DateFormat dateFormat = DateFormat('dd MMM yyyy, HH:mm:ss');
    final currentPoints = _getCurrentPagePoints();

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
                  value: _selectAll,
                  onChanged: (value) => _toggleSelectAll(value),
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
            currentPoints.length,
            (index) {
              final point = currentPoints[index];
              final recordedAt = point.createdAt;
              final latitude = point.latitude;
              final longitude = point.longitude;

              final DateTime parsedDate = DateTime.parse(recordedAt!);
              final String formattedDate = dateFormat.format(parsedDate);
              final isSelected = _selectedItems.contains(point.id.toString());

              return DataRow(
                cells: [
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(index, value),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Points", fontSize: 40),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }

}