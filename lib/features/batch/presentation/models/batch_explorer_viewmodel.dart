import 'dart:async';

import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_viewmodel.dart';
import 'package:dawarich/features/batch/presentation/converters/local_point_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

class UploadProgress {
  final int uploaded;
  final int total;

  const UploadProgress(this.uploaded, this.total)
      : assert(total >= 0, 'Total must not be negative'),
        assert(uploaded >= 0, 'Uploaded must not be negative');

  double get fraction => total > 0
      ? (uploaded / total).clamp(0.0, 1.0)
      : 0.0;

  bool get isMeaningful => total > 0;
}

final class BatchExplorerViewModel extends ChangeNotifier {

  StreamSubscription<List<LocalPoint>>? _batchSubscription;

  List<LocalPointViewModel> _batch = [];
  List<LocalPointViewModel> get batch => _batch;
  int _itemsPerPage = 100;
  int get _currentPage => (_batch.length / _itemsPerPage)
      .ceil().clamp(1, double.infinity).toInt();

  final _uploadResultController = StreamController<String>.broadcast();
  Stream<String> get uploadResultStream => _uploadResultController.stream;

  final _progressController = StreamController<UploadProgress>.broadcast();
  Stream<UploadProgress> get uploadProgress => _progressController.stream;

  List<LocalPointViewModel> get visibleBatch {
    final end = (_itemsPerPage * _currentPage).clamp(0, _batch.length);
    return _batch.take(end).toList();
  }

  bool _newestFirst = true;
  bool get newestFirst => _newestFirst;

  bool get hasPoints => visibleBatch.isNotEmpty;

  bool _isLoadingPoints = true;
  bool get isLoadingPoints => _isLoadingPoints;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  final LocalPointService _localPointService;
  BatchExplorerViewModel(this._localPointService);

  void _setBatch(List<LocalPointViewModel> batch) {
    _batch = batch;
    notifyListeners();
  }

  void setIsUploading(bool trueOrFalse) {
    _isUploading = trueOrFalse;
    notifyListeners();
  }

  void _setIsLoadingPoints(bool trueOrFalse) {
    _isLoadingPoints = trueOrFalse;
    notifyListeners();
  }

  void toggleSortOrder() {
    _newestFirst = !_newestFirst;
    _sortBatch();
    notifyListeners();
  }

  void _sortBatch() {
    _batch.sort((a, b) {
      final aTime = DateTime.parse(a.properties.timestamp);
      final bTime = DateTime.parse(b.properties.timestamp);
      return _newestFirst ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
    });
  }

  bool _hasInitialized = false;
  bool get hasInitialized => _hasInitialized;

  void setInitialized(bool value) {
    _hasInitialized = value;
    notifyListeners();
  }

  Future<void> initialize() async {

    if (kDebugMode) {
      debugPrint("[BatchExplorerViewModel] Initializing...");
    }

    if (_batchSubscription != null) {
      return;
    }

    final stream = await _localPointService.watchCurrentBatch();

    _batchSubscription = stream.listen((batch) async {
      final batchVm = await compute(BatchExplorerViewModel._convertToViewModels, batch);

      batchVm.sort((a, b) {
        final aTime = DateTime.parse(a.properties.timestamp);
        final bTime = DateTime.parse(b.properties.timestamp);
        return _newestFirst ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
      });

      _setBatch(batchVm);
      _setIsLoadingPoints(false);

      if (!hasInitialized) {
        setInitialized(true);
      }
    });
  }

  static List<LocalPointViewModel> _convertToViewModels(List<LocalPoint> points) {
    return points.map((point) => point.toViewModel()).toList();
  }

  Future<void> uploadBatch() async {

    setIsUploading(true);

    List<LocalPoint> localPoints = _batch
        .map((point) => point.toDomain())
        .toList();

    Result<(), String> uploadResult = await _localPointService
        .prepareBatchUpload(localPoints, onChunkUploaded: (uploaded, total) {
      _progressController.add(UploadProgress(uploaded, total));
    });

    if (uploadResult case Err(value: final String error)) {
      _uploadResultController.add(error);
    }

    _progressController.add(const UploadProgress(0, 0));

    setIsUploading(false);
  }

  Future<void> deletePoints(List<LocalPointViewModel> points) async {

    List<int> pointIds = points.map((point) => point.id).toList();
    await _localPointService.deletePoints(pointIds);
    batch.removeWhere((point) => pointIds.contains(point.id));
    notifyListeners();
  }

  Future<void> clearBatch() async {
    await _localPointService.clearBatch();
    batch.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _batchSubscription?.cancel();
    super.dispose();
  }
}
