import 'package:flutter/foundation.dart';

/// A mixin that provides safe notification handling for ChangeNotifier subclasses.
///
/// This mixin tracks disposal state and provides a [safeNotifyListeners] method
/// that only calls [notifyListeners] if the notifier hasn't been disposed.
mixin SafeChangeNotifier on ChangeNotifier {
  bool _isDisposed = false;

  /// Returns true if this notifier has been disposed.
  bool get isDisposed => _isDisposed;

  /// Safely calls [notifyListeners] only if the notifier hasn't been disposed.
  /// Returns true if listeners were notified, false if disposed.
  @protected
  bool safeNotifyListeners() {
    if (_isDisposed) {
      return false;
    }
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
