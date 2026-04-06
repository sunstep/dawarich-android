
import 'package:dawarich/features/version_check/domain/server_compatibility_state.dart';

abstract interface class IServerCompatibilityStore {
  Future<void> set(ServerCompatibilityState state);
}