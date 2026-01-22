import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/migration/presentation/viewmodels/migration_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:session_box/session_box.dart';

import 'core_providers.dart';


final migrationViewModelProvider = FutureProvider<MigrationViewModel>((ref) async {
  final SQLiteClient db = await ref.watch(sqliteClientProvider.future);
  final SessionBox<User> sessionBox = await ref.watch(sessionBoxProvider.future);

  final vm = MigrationViewModel(db, sessionBox);
  ref.onDispose(vm.dispose);

  return vm;
});
