import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/batch/application/usecases/batch_upload_workflow_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/clear_batch_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/delete_points_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/watch_current_batch_usecase.dart';
import 'package:dawarich/features/batch/presentation/viewmodels/batch_explorer_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final batchExplorerViewModelProvider =
    FutureProvider.autoDispose<BatchExplorerViewModel>((ref) async {
  final user = ref.watch(authenticatedUserProvider);
  if (user == null) {
    throw StateError('BatchExplorerViewModel requires authenticated user');
  }

  final IPointLocalRepository localRepo = await ref.watch(pointLocalRepositoryProvider.future);
  final IApiPointRepository apiRepo = await ref.watch(apiPointRepositoryProvider.future);

  final watchCurrentBatch = WatchCurrentBatchUseCase(localRepo);
  final uploadWorkflow = BatchUploadWorkflowUseCase(apiRepo, localRepo);
  final clearBatch = ClearBatchUseCase(localRepo);
  final deletePoints = DeletePointsUseCase(localRepo);

  final vm = BatchExplorerViewModel(
    user.id,
    watchCurrentBatch,
    uploadWorkflow,
    clearBatch,
    deletePoints,
  )..initialize();

  ref.onDispose(vm.dispose);
  return vm;
});