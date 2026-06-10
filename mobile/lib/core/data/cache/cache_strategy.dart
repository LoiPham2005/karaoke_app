// 📁 lib/core/data/cache/cache_strategy.dart
// TTL constants dùng chung — thay cho cache_strategy.dart + cache_config.dart
//
// Dùng:
//   await cache.setJson('key', data, ttl: CacheTtl.short);
//   await cache.setJson('key', data, ttl: CacheTtl.day);

abstract final class CacheTtl {
  static const short = Duration(minutes: 5); // data thay đổi thường
  static const medium = Duration(hours: 1); // data ổn định
  static const long = Duration(days: 1); // data ít thay đổi
  static const week = Duration(days: 7);
  static const permanent = Duration(days: 365); // static data
}

/// Các chiến lược cache cho network request.
enum CacheStrategy {
  /// Không dùng cache, luôn fetch từ network.
  noCache(null),

  /// Cache ngắn hạn (5 phút).
  shortTerm(CacheTtl.short),

  /// Cache trung bình (1 giờ).
  mediumTerm(CacheTtl.medium),

  /// Cache dài hạn (1 ngày).
  longTerm(CacheTtl.long),

  /// Cache vĩnh viễn (1 năm).
  permanent(CacheTtl.permanent),

  /// Ưu tiên cache, nếu không có mới fetch.
  cacheFirst(CacheTtl.medium),

  /// Ưu tiên fetch, nếu lỗi mới dùng cache (fallback).
  networkFirst(CacheTtl.medium);

  final Duration? ttl;
  const CacheStrategy(this.ttl);
}
