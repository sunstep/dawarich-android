
import 'dart:async';

final class ReactivePeriodicTicker {

  final Stream<Duration> _period$;
  final _ticks = StreamController<void>.broadcast();
  final _resets = StreamController<void>();
  StreamSubscription<Duration>? _periodSub;
  StreamSubscription<void>? _resetSub;
  Timer? _timer;
  Duration _current = const Duration(seconds: 1);
  bool _running = false;

  ReactivePeriodicTicker(this._period$);

  Stream<void> get ticks => _ticks.stream;

  /// Start emitting ticks; if [immediate] true, emit once instantly.
  void start({bool immediate = false}) {
    if (_running) return;
    _running = true;

    _periodSub = _period$.listen((d) {
      _current = d > Duration.zero ? d : const Duration(seconds: 1);
      _restartTimer();
    });

    _resetSub = _resets.stream.listen((_) => _restartTimer());

    if (immediate) {
      if (!_ticks.isClosed) _ticks.add(null);
    }
    _restartTimer();
  }

  /// Snooze/refresh the countdown (e.g., after a cached point).
  void snooze() => _resets.add(null);

  void _restartTimer() {
    _timer?.cancel();
    if (!_running) return;
    _timer = Timer.periodic(_current, (_) {
      if (!_ticks.isClosed) _ticks.add(null);
    });
  }

  Future<void> stop() async {
    _running = false;
    _timer?.cancel(); _timer = null;
    await _periodSub?.cancel(); _periodSub = null;
    await _resetSub?.cancel(); _resetSub = null;
  }

  Future<void> dispose() async {
    await stop();
    await _ticks.close();
    await _resets.close();
  }

}