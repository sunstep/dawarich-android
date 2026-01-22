
import 'dart:async';

final class DbGate {
  DbGate({bool initiallyOpen = false}) : _isOpen = initiallyOpen {
    if (initiallyOpen) {
      _openCompleter.complete();
    }
  }

  bool _isOpen;
  final Completer<void> _openCompleter = Completer<void>();

  bool get isOpen => _isOpen;

  void lock() {
    if (_isOpen) {
      
      _isOpen = false;
    }
  }

  void open() {
    if (_isOpen) {
      return;
    }
    _isOpen = true;

    if (!_openCompleter.isCompleted) {
      _openCompleter.complete();
    }
  }

  Future<void> waitUntilOpen() async {
    if (_isOpen) {
      return;
    }
    await _openCompleter.future;
  }

  Future<T> withOpen<T>(Future<T> Function() action) async {
    await waitUntilOpen();
    return await action();
  }
}