import 'package:dawarich/application/entities/api/points/response/api_point.dart';
import 'package:dawarich/application/services/point_service.dart';
import 'package:dawarich/ui/models/api/points/response/api_point_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:option_result/option_result.dart';

class PointsPageViewModel with ChangeNotifier {

  final PointService _pointService = GetIt.I<PointService>();

  late DateTime _startDate;
  late DateTime _endDate;

  bool _isLoading = true;
  bool _selectAll = false;
  bool _sortByNew = true;
  int _currentPage = 1;
  int _totalPages = 0;
  final int _pointsPerPage = 100;

  List<ApiPointViewModel> _points = [];
  List<ApiPointViewModel> _pagePoints = [];

  Set<String> _selectedItems = {};

  PointsPageViewModel() {
    DateTime now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 999, 999);
  }

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  bool get isLoading => _isLoading;
  bool get selectAll => _selectAll;
  bool get sortByNew => _sortByNew;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pointsPerPage => _pointsPerPage;

  List<ApiPointViewModel> get points => _points;
  List<ApiPointViewModel> get pagePoints => _pagePoints;

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

  void setSelectAll(bool trueOrFalse) {
    _selectAll = trueOrFalse;
    notifyListeners();
  }

  void setSortByNew(bool trueOrFalse) {
    _sortByNew = trueOrFalse;
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

  void setSelectedItems(Set<String> points){
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

  void setPagePoints(List<ApiPointViewModel> list) {
    _pagePoints = list;
    notifyListeners();
  }

  void clearPagedPoints() {
    _pagePoints.clear();
    notifyListeners();
  }

  void setCurrentPagePoints() {

    final int start = (currentPage - 1) * pointsPerPage;
    final int end = start + pointsPerPage;

    if (start >= points.length) {
      pagePoints.clear();
    }

    setPagePoints(points.sublist(start, end > points.length ? points.length : end));
  }

  Future<void> initialize() async {

    setLoading(true);

    int amountOfPages = await _pointService.getTotalPages(startDate, endDate, pointsPerPage);
    setTotalPages(amountOfPages);

    Option<List<ApiPoint>> result =  await _pointService.fetchAllPoints(startDate, endDate, pointsPerPage);

    switch (result) {

      case Some(value: List<ApiPoint> fetchedPoints): {

        List<ApiPointViewModel> points = fetchedPoints
            .map((point) => ApiPointViewModel(point))
            .toList();

        setPoints(points);
        setCurrentPagePoints();

        setLoading(false);
      }

      case None(): {
        // Handle error
      }
    }

  }

  Future<void> searchPressed() async {

    setLoading(true);
    clearPoints();

    int amountOfPages = await _pointService.getTotalPages(startDate, endDate, pointsPerPage);
    setTotalPages(amountOfPages);

    setCurrentPage(1);

    Option<List<ApiPoint>> result = await _pointService.fetchAllPoints(startDate, endDate, pointsPerPage);

    switch (result) {
      case Some(value: List<ApiPoint> fetchedPoints): {

        List<ApiPointViewModel> points = fetchedPoints
            .map((point) => ApiPointViewModel(point))
            .toList();

        setPoints(points);
        getCurrentPagePoints();
        sortPoints();

        setLoading(false);
      }

      case None(): {
        // Edit view to error page
      }
    }

  }

  List<ApiPointViewModel> getCurrentPagePoints() {

    final int start = (pagePoints.length - 1) * pointsPerPage;
    final int end = start + pointsPerPage;

    if (start >= points.length) {
      return [];
    }

    List<ApiPointViewModel> newList = points.sublist(start, end > points.length ? points.length : end);
    return newList;
  }

  Future<void> deleteSelection() async {

    final selectedItemsCopy = selectedItems.toList();

    for (String pointId in selectedItemsCopy){

      bool deleted = await _pointService.deletePoint(pointId);

      if (deleted) {

        points.removeWhere((point) => point.id.toString() == pointId);
        selectedItems.remove(pointId);
        setSelectAll(_isAllSelected());
      }
    }
  }

  void navigateFirst() {

    if (currentPage > 0) {

      _isLoading = true;
      _currentPage = 1;

      setCurrentPagePoints();

      _isLoading = false;
    }
  }

  void navigateBack() {

    if (currentPage > 1) {

      _isLoading = true;
      _currentPage--;

      setCurrentPagePoints();

      _isLoading = false;
    }
  }

  void navigateNext() {

    if (currentPage < totalPages) {

      _isLoading = true;
      _currentPage++;

      setCurrentPagePoints();

      _isLoading = false;

    }
  }

  void navigateLast() {

    if (currentPage < totalPages) {

      _isLoading = true;
      _currentPage = totalPages;

      setCurrentPagePoints();

      _isLoading = false;

    }
  }


  void toggleSelectAll() {

    setSelectAll(!selectAll);

    if (selectAll) {
      setSelectedItems(getCurrentPagePoints().map((point) => point.id.toString()).toSet());
    } else {
      clearSelectedItems();
    }
  }


  void toggleSelection(int index, bool? value) {

    final String pointId = points[index].id.toString();

    if (value == true) {
      _selectedItems.add(pointId);
    } else {
      _selectedItems.remove(pointId);
    }

    setSelectAll(_isAllSelected());
  }

  void toggleSort() {

    _sortByNew = !_sortByNew;
    notifyListeners();
  }

  void sortPoints() {


    points.sort((a, b) {
      DateTime dateA = DateTime.fromMillisecondsSinceEpoch(a.timestamp! * 1000);
      DateTime dateB = DateTime.fromMillisecondsSinceEpoch(b.timestamp! * 1000);
      return _sortByNew ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    setCurrentPagePoints();
  }

  bool hasSelectedItems() => _selectedItems.isNotEmpty;
  bool _isAllSelected() => _selectedItems.length == pointsPerPage;


}