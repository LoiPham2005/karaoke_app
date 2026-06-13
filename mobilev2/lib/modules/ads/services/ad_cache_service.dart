import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/services/utils/logger.dart';

/// In-memory cache cho Ad object — TTL 1h theo AdMob policy.
///
/// Tự dispose ad cũ khi:
/// - `set()` overwrite key đã có.
/// - `get()` phát hiện expired.
/// - `remove()` / `clear()`.
///
/// Safe-dispose: bắt mọi exception khi dispose để tránh "Ad already disposed"
/// crash khi caller cũng dispose từ bên ngoài.
@lazySingleton
class AdCacheService {
  final Map<String, Ad> _cache = {};
  final Map<String, DateTime> _loadTimes = {};

  static const Duration _expiry = Duration(hours: 1);
  static const _tag = 'ADS CACHE';

  int hits = 0;
  int misses = 0;
  int expirations = 0;

  void set(String key, Ad ad) {
    _safeDispose(key);
    _cache[key] = ad;
    _loadTimes[key] = DateTime.now();
  }

  T? get<T extends Ad>(String key) {
    final ad = _cache[key];
    final loadTime = _loadTimes[key];

    if (ad == null || loadTime == null) {
      misses++;
      return null;
    }

    if (DateTime.now().difference(loadTime) > _expiry) {
      expirations++;
      Logger.info('[$key] expired (>1h)', tag: _tag);
      remove(key);
      return null;
    }

    hits++;
    return ad as T;
  }

  void remove(String key) {
    _safeDispose(key);
    _cache.remove(key);
    _loadTimes.remove(key);
  }

  bool isReady(String key) => get(key) != null;

  void clear() {
    for (final key in _cache.keys.toList()) {
      _safeDispose(key);
    }
    _cache.clear();
    _loadTimes.clear();
  }

  /// Debug-only — hit rate summary.
  String get statsLabel {
    final total = hits + misses;
    final rate = total == 0 ? '—' : '${(hits / total * 100).toStringAsFixed(1)}%';
    return 'hits=$hits | misses=$misses | exp=$expirations | rate=$rate';
  }

  void _safeDispose(String key) {
    final ad = _cache[key];
    if (ad == null) return;
    try {
      ad.dispose();
    } catch (e) {
      Logger.warning('[$key] dispose threw: $e', tag: _tag);
    }
  }
}
