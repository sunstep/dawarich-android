import 'package:dawarich/core/application/usecases/api/delete_point_usecase.dart';
import 'package:dawarich/core/application/usecases/api/get_points_usecase.dart';
import 'package:dawarich/core/application/usecases/api/get_total_pages_usecase.dart';
import 'package:dawarich/core/domain/models/point/api/api_point.dart';
import 'package:dawarich/features/points/presentation/models/api_point_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:option_result/option_result.dart';

final class PointsPageViewModel with ChangeNotifier {

  late DateTime _startDate;
  late DateTime _endDate;

  bool _isLoading = true;
  bool _displayFilters = true;
  bool _selectAll = false;
  bool _sortByNew = true;
  bool _showUnGeocoded = false;
  int _currentPage = 1;
  int _totalPages = 0;
  final int _pointsPerPage = 100;

  List<ApiPointViewModel> _points = [];

  Set<String> _selectedItems = {};

  final GetPointsUseCase _getPointsUseCase;
  final DeletePointUseCase _deletePointUseCase;
  final GetTotalPagesUseCase _getTotalPagesUseCase;

  PointsPageViewModel(this._getPointsUseCase, this._deletePointUseCase, this._getTotalPagesUseCase) {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  }

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  String get formattedStart => DateFormat.yMMMd().add_Hm().format(_startDate);
  String get formattedEnd => DateFormat.yMMMd().add_Hm().format(_endDate);

  bool get isLoading => _isLoading;
  bool get displayFilters => _displayFilters;
  bool get selectAll => _selectAll;
  bool get sortByNew => _sortByNew;
  bool get showUnGeocoded => _showUnGeocoded;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pointsPerPage => _pointsPerPage;

  List<ApiPointViewModel> get pagePoints {

    final filtered = _showUnGeocoded
        ? _points
        : _points.where((p) => p.geodata?.geometry?.coordinates != null).toList();

    final int start = (currentPage - 1) * pointsPerPage;
    final int end = start + pointsPerPage;
    final safeStart = start.clamp(0, filtered.length);
    final safeEnd = end.clamp(0, filtered.length);

    return filtered.sublist(safeStart, safeEnd);
  }

  Set<String> get selectedItems => _selectedItems;

  void setStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void setLoading(bool trueOrFalse) {
    _isLoading = trueOrFalse;
    notifyListeners();
  }

  void toggleDisplayFilters() {
    _displayFilters = !_displayFilters;
    notifyListeners();
  }

  void setSelectAll(bool trueOrFalse) {
    _selectAll = trueOrFalse;
    notifyListeners();
  }

  void setSortByNew(bool trueOrFalse) {
    _sortByNew = trueOrFalse;
    notifyListeners();
  }

  void toggleShowUnGeocoded(bool value) {
    _showUnGeocoded = value;
    notifyListeners();
  }

  void setCurrentPage(int number) {
    _currentPage = number;
    notifyListeners();
  }

  void setTotalPages(int number) {
    _totalPages = number;
    notifyListeners();
  }

  void setPoints(List<ApiPointViewModel> list) {
    _points = list;
    notifyListeners();
  }

  void selectPoint(String pointId) {
    _selectedItems.add(pointId);
    notifyListeners();
  }

  void setSelectedItems(Set<String> points) {
    _selectedItems = points;
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  void clearPoints() {
    _points.clear();
    notifyListeners();
  }

  Future<void> initialize() async {

    searchPressed();
  }

  Future<void> searchPressed() async {
    setLoading(true);
    clearPoints();

    int amountOfPages =
        await _getTotalPagesUseCase(startDate, endDate, pointsPerPage);
    setTotalPages(amountOfPages);

    setCurrentPage(1);

    Option<List<ApiPoint>> result =
        await _getPointsUseCase(
            startDate: startDate,
            endDate:  endDate,
            perPage:  pointsPerPage
        );

    if (result case Some(value: List<ApiPoint> fetchedPoints)) {
      List<ApiPointViewModel> points =
          fetchedPoints.map((point) => ApiPointViewModel(point)).toList();

      if (kDebugMode) {
        debugPrint('[DEBUG] Fetched ${points.length} points');
      }

      setPoints(points);
      sortPoints();
      setLoading(false);
    } else {
      // to do
      setLoading(false);
    }

  }

  Future<void> deleteSelection() async {
    final selectedItemsCopy = selectedItems.toList();

    for (String pointId in selectedItemsCopy) {
      bool deleted = await _deletePointUseCase(pointId);

      if (deleted) {
        _points.removeWhere((point) => point.id.toString() == pointId);
        selectedItems.remove(pointId);
        setSelectAll(_isAllSelected());
      }
    }
  }

  void navigateFirst() {
    if (currentPage > 0) {
      setCurrentPage(1);
    }
  }

  void navigateBack() {
    if (currentPage > 1) {
      setCurrentPage(--_currentPage);
    }
  }

  void navigateNext() {
    if (currentPage < totalPages) {
      setCurrentPage(++_currentPage);
    }
  }

  void navigateLast() {
    if (currentPage < totalPages) {
      setCurrentPage(totalPages);
    }
  }

  void toggleSelectAll() {
    setSelectAll(!selectAll);

    if (selectAll) {
      setSelectedItems(
          pagePoints.map((point) => point.id.toString()).toSet());
    } else {
      clearSelectedItems();
    }
  }

  void setAllSelected(bool? value) {
    if (value == true) {
      for (final p in pagePoints) {
        selectedItems.add(p.id.toString());
      }
    } else {
      for (final p in pagePoints) {
        selectedItems.remove(p.id.toString());
      }
    }
    notifyListeners();
  }

  void toggleSelection(int index, bool? value) {
    final String pointId = pagePoints[index].id.toString();

    if (value == true) {
      _selectedItems.add(pointId);
    } else {
      _selectedItems.remove(pointId);
    }

    setSelectAll(_isAllSelected());
  }

  void toggleSort() {
    _sortByNew = !_sortByNew;
    sortPoints();
    notifyListeners();
  }

  void sortPoints() {
    _points.sort((a, b) {
      DateTime dateA = DateTime.fromMillisecondsSinceEpoch(a.timestamp! * 1000);
      DateTime dateB = DateTime.fromMillisecondsSinceEpoch(b.timestamp! * 1000);
      return _sortByNew ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    notifyListeners();

  }

  bool hasSelectedItems() => _selectedItems.isNotEmpty;
  bool _isAllSelected() => _selectedItems.length == pagePoints.length;

}
