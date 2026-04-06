import 'package:dawarich/features/version_check/application/repository/server_compatibility_store.dart';
import 'package:dawarich/features/version_check/domain/server_compatibility_state.dart';
import 'package:dawarich/features/version_check/presentation/server_compatibility_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class RiverpodServerCompatibilityStore
    implements IServerCompatibilityStore {
  final Ref _ref;
  RiverpodServerCompatibilityStore(this._ref);

  @override
  Future<void> set(ServerCompatibilityState state) async {
    _ref.read(serverCompatibilityProvider.notifier).setState(state);
  }
}