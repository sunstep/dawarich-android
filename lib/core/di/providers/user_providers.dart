

import 'package:dawarich/core/database/repositories/drift/drift_user_repository.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

final userRepositoryProvider = FutureProvider<IUserRepository>((ref) async {
  final db = await ref.watch(sqliteClientProvider.future);
  return DriftUserRepository(db);
});