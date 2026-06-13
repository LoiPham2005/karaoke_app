import 'dart:async';
import 'dart:math' as math;

/// Exponential backoff cho ad load retry.
///
/// Mặc định: 2s → 4s → 8s → max 30s, tối đa 3 retries.
/// Jitter ±20% để tránh thundering herd khi network khôi phục.
class AdRetryPolicy {
  const AdRetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
    this.maxDelay = const Duration(seconds: 30),
    this.jitterRatio = 0.2,
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final double jitterRatio;

  /// `attempt` bắt đầu từ 1 (lần retry đầu tiên sau fail).
  Duration delayFor(int attempt) {
    if (attempt <= 0) return Duration.zero;
    final exp = baseDelay.inMilliseconds * math.pow(2, attempt - 1);
    final capped = math.min(exp.toDouble(), maxDelay.inMilliseconds.toDouble());
    final jitter = (math.Random().nextDouble() * 2 - 1) * jitterRatio * capped;
    return Duration(milliseconds: (capped + jitter).clamp(0, double.infinity).toInt());
  }

  bool shouldRetry(int attempt) => attempt < maxRetries;
}

/// Tracker per-placement — count attempts + cancel pending timer khi dispose
/// hoặc khi success.
class AdRetryTracker {
  AdRetryTracker(this.policy);

  final AdRetryPolicy policy;
  final Map<String, int> _attempts = {};
  final Map<String, Timer> _timers = {};

  int attemptsFor(String key) => _attempts[key] ?? 0;

  /// Schedule retry; trả `false` nếu đã hết quota.
  bool scheduleRetry(String key, void Function() action) {
    final current = _attempts[key] ?? 0;
    if (!policy.shouldRetry(current)) return false;

    final next = current + 1;
    _attempts[key] = next;
    _timers[key]?.cancel();
    _timers[key] = Timer(policy.delayFor(next), () {
      _timers.remove(key);
      action();
    });
    return true;
  }

  void reset(String key) {
    _attempts.remove(key);
    _timers.remove(key)?.cancel();
  }

  void clear() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _attempts.clear();
  }
}
