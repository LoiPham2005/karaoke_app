// 📁 lib/core/cache/cache_service.dart
// Thay thế toàn bộ: app_cache_manager, local_cache_dao, cache_config,
//                   cache_strategy, cache_stats, app_database (cache part)
//
// ══ DÙNG ═══════════════════════════════════════════════════════
// final cache = getIt<CacheService>();
//
// // Lưu / đọc
// await cache.setString('token', 'abc123');
// await cache.getString('token');
//
// await cache.setJson('user', user.toJson(), ttl: Duration(hours: 1));
// await cache.getJson('user');
//
// // Xóa
// await cache.remove('token');
// await cache.removeByPrefix('user_');
// await cache.clear();
//
// // Ảnh / file
// cache.imageCache   → CacheManager (dùng với CachedNetworkImage)
// cache.fileCache    → CacheManager (video, doc...)
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/utils/logger.dart';

@lazySingleton
class CacheService {
  static const _tag = 'CACHE';
  static const _expiryPrefix = '__exp__';

  // ── File caches ───────────────────────────────────────────────

  final imageCache = CacheManager(
    Config(
      'imageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
    ),
  );

  final fileCache = CacheManager(
    Config(
      'fileCache',
      stalePeriod: const Duration(days: 60),
      maxNrOfCacheObjects: 200,
    ),
  );

  // ── Init ──────────────────────────────────────────────────────

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _clearExpired();
    Logger.success('Cache ready', tag: _tag);
  }

  // ── String ────────────────────────────────────────────────────

  Future<void> setString(String key, String value, {Duration? ttl}) async {
    final p = await _p;
    await p.setString(key, value);
    if (ttl != null) await p.setInt(_expiryKey(key), _expiryMs(ttl));
  }

  Future<String?> getString(String key) async {
    if (await _isExpired(key)) return null;
    return (await _p).getString(key);
  }

  // ── JSON ──────────────────────────────────────────────────────

  Future<void> setJson(String key, dynamic value, {Duration? ttl}) =>
      setString(key, jsonEncode(value), ttl: ttl);

  Future<T?> getJson<T>(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      await remove(key);
      return null;
    }
  }

  // ── Bool / Int ────────────────────────────────────────────────

  Future<void> setBool(String key, bool value) async =>
      (await _p).setBool(key, value);
  Future<bool?> getBool(String key) async => (await _p).getBool(key);

  Future<void> setInt(String key, int value) async =>
      (await _p).setInt(key, value);
  Future<int?> getInt(String key) async => (await _p).getInt(key);

  // ── Get or Fetch ──────────────────────────────────────────────

  /// Cache-aside pattern: đọc cache → nếu miss thì fetch rồi lưu lại.
  ///
  /// ```dart
  /// final user = await cache.getOrFetch(
  ///   key: 'user_profile',
  ///   ttl: Duration(hours: 1),
  ///   fetch: () => api.getUser(),
  ///   encode: (u) => u.toJson(),
  ///   decode: UserModel.fromJson,
  /// );
  /// ```
  Future<T?> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    required Map<String, dynamic> Function(T) encode,
    required T Function(Map<String, dynamic>) decode,
    Duration? ttl,
  }) async {
    final cached = await getJson(key);
    if (cached != null) {
      try {
        return decode(cached);
      } catch (_) {
        await remove(key);
      }
    }
    try {
      final data = await fetch();
      await setJson(key, encode(data), ttl: ttl);
      return data;
    } catch (e) {
      Logger.error('getOrFetch failed: $key', error: e, tag: _tag);
      return null;
    }
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<void> remove(String key) async {
    final p = await _p;
    await p.remove(key);
    await p.remove(_expiryKey(key));
  }

  /// Xóa tất cả key có prefix — ví dụ: removeByPrefix('user_')
  Future<void> removeByPrefix(String prefix) async {
    final p = await _p;
    final keys = p.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await p.remove(k);
    }
  }

  /// Xóa toàn bộ SharedPreferences + file caches
  Future<void> clear() async {
    await (await _p).clear();
    await Future.wait([imageCache.emptyCache(), fileCache.emptyCache()]);
    Logger.info('All caches cleared', tag: _tag);
  }

  /// Chỉ xóa file cache (ảnh, video, doc)
  Future<void> clearFileCache() =>
      Future.wait([imageCache.emptyCache(), fileCache.emptyCache()]);

  // ── Private ───────────────────────────────────────────────────

  String _expiryKey(String key) => '$_expiryPrefix$key';
  int _expiryMs(Duration ttl) => DateTime.now().add(ttl).millisecondsSinceEpoch;

  Future<bool> _isExpired(String key) async {
    final p = await _p;
    final expiry = p.getInt(_expiryKey(key));
    if (expiry == null) return false;
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await p.remove(key);
      await p.remove(_expiryKey(key));
      return true;
    }
    return false;
  }

  Future<void> _clearExpired() async {
    final p = await _p;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = p
        .getKeys()
        .where((k) => k.startsWith(_expiryPrefix))
        .where((k) => (p.getInt(k) ?? 0) < now)
        .map((k) => k.replaceFirst(_expiryPrefix, ''))
        .toList();
    for (final k in expiredKeys) {
      await remove(k);
    }
    if (expiredKeys.isNotEmpty) {
      Logger.info('Cleared ${expiredKeys.length} expired entries', tag: _tag);
    }
  }
}
