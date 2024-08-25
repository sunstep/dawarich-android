import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dawarich/widgets/drawer.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _selectAll = false;
  List<dynamic> _points = [];
  Set<String> _selectedItems = {};
  bool _isLoading = true;
  bool _sortByNew = true;

  int _currentPage = 0;
  final int _pointsPerPage = 150;
  int get _totalPages => (_points.length / _pointsPerPage).floor();

  List<dynamic> _getCurrentPagePoints() {
    final start = _currentPage * _pointsPerPage;
    final end = start + _pointsPerPage;

    if (start >= _points.length) {
      return [];
    }

    return _points.sublist(start, end > _points.length ? _points.length : end);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    await _fetchEndpointInfo();
    await _fetchPoints();
  }

  Future<void> _fetchEndpointInfo() async {
    const storage = FlutterSecureStorage();
    _endpoint = await storage.read(key: "host");
    _apiKey = await storage.read(key: "api_key");
  }

  Future<void> _fetchPoints() async {

    final startDate =
    DateTime(_startDate.year, _startDate.month, _startDate.day)
        .toIso8601String();
    final endDate = DateTime(_endDate.year, _endDate.month,
        _endDate.day, 23, 59, 59)
        .toIso8601String();

    final uri = Uri.parse('$_endpoint/api/v1/points?api_key=$_apiKey&start_at=$startDate&end_at=$endDate');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        _points = jsonDecode(response.body);
        _points.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA);
        });
        _selectedItems = {};
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load points');
    }
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _toggleSelectAll(bool? value) {

    setState(() {

      _selectAll = !_selectAll;

      if (value == true){
        _selectedItems = _getCurrentPagePoints().map((point) => point['id'].toString()).toSet();
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _toggleSelection(int index, bool? value) {

    final String pointId = _points[index]['id'].toString();

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
        _points.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA);
        });
      } else {
        _points.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateA.compareTo(dateB);
        });
      }
    });
  }

  bool hasSelectedItems() => _selectedItems.isNotEmpty;

  Future<void> _searchPressed() async {
    setState(() {
      _isLoading = true;
      _points.clear();
      _currentPage = 0;

    });

    await _fetchPoints();
  }

  bool _isAllSelected() => _selectedItems.length == _pointsPerPage;

  Future<void> _deleteSelection() async {

    final selectedItemsCopy = _selectedItems.toList();

    for (String pointId in selectedItemsCopy){
      final uri = Uri.parse("$_endpoint/api/v1/points/$pointId?api_key=$_apiKey");
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        setState(() {
          _points.removeWhere((point) => point['id'].toString() == pointId);
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

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final borderColor = Theme.of(context).dividerColor;

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
                        text: '${_startDate.toLocal()}'.split(' ')[0],
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
                        text: '${_endDate.toLocal()}'.split(' ')[0],
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
                const SizedBox(width: 30),
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
                    if (_points.length > _pointsPerPage && !hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_currentPage != 0){
                              _currentPage = 0;
                            }
                          });
                        },
                        icon: const Icon(Icons.first_page),
                      ),
                    if (_points.length > _pointsPerPage && !hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_currentPage > 0){
                              _currentPage--;
                            }
                          });
                        },
                        icon: const Icon(Icons.navigate_before),
                      ),
                    if (!hasSelectedItems())
                      Text("${_currentPage+1}/${_totalPages+1}"),
                    if (!hasSelectedItems())
                      const SizedBox(width: 8),
                    if (_points.length > _pointsPerPage && !hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_currentPage != _totalPages){
                              _currentPage++;
                            }
                          });
                        },
                        icon: const Icon(Icons.navigate_next),
                      ),
                    if (_points.length > _pointsPerPage && !hasSelectedItems())
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_currentPage < _totalPages){
                              _currentPage = _totalPages;
                            }
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
              const Checkbox(value: false, onChanged: null),
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
              final recordedAt = point['created_at'];
              final latitude = point['latitude'];
              final longitude = point['longitude'];

              final DateTime parsedDate = DateTime.parse(recordedAt);
              final String formattedDate = dateFormat.format(parsedDate);
              final isSelected = _selectedItems.contains(point['id'].toString());

              return DataRow(
                cells: [
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(index, value),
                      side: BorderSide(color: checkColor),
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