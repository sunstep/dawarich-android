@Deprecated('GetIt DI has been removed. Use Riverpod providers under core/di/providers instead.')
final class DependencyInjection {
  static Future<void> injectDependencies() async {
    // No-op. Kept only as a placeholder to avoid breaking older imports.
  }

  static Future<void> injectBackgroundDependencies(Object instance) async {
    // No-op.
  }

  static Future<void> disposeBackgroundDependencies() async {
    // No-op.
  }
}
