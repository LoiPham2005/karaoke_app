// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/bloc_manager.dart
// ════════════════════════════════════════════════════════════════
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/injection.dart';

/// 🎯 BlocManager — Quản lý lifecycle BLoC/Cubit với ref-counting
///
/// ```dart
/// // Singleton (shared toàn app)
/// BlocManager.get<ProductCubit>();
///
/// // Scoped (2 instance cùng type)
/// BlocManager.get<DetailCubit>(key: 'product_$id');
///
/// // Factory (truyền params, không qua GetIt)
/// BlocManager.getWith(() => DetailCubit(id: 123), key: 'detail_123');
///
/// // Test override — dùng trong setUp/tearDown
/// BlocManager.addOverride<ProductCubit>(() => MockProductCubit());
/// BlocManager.clearTestOverrides(); // trong tearDown
/// ```
class BlocManager {
  BlocManager._();

  static final _instances  = <String, BlocBase>{};
  static final _refCounts  = <String, int>{};
  static final _overrides  = <String, BlocBase Function()>{};

  static String _key<T>(String? scopeKey) => scopeKey == null ? '$T' : '$T:$scopeKey';

  // ── Get ───────────────────────────────────────────────────────

  /// Lấy hoặc tạo BLoC từ GetIt. Tự tạo lại nếu đã bị closed.
  static T get<T extends BlocBase>({String? key}) => _acquire(_key<T>(key), () => getIt<T>());

  /// Lấy hoặc tạo BLoC bằng factory (khi cần truyền params).
  static T getWith<T extends BlocBase>(T Function() factory, {String? key}) =>
      _acquire(_key<T>(key), factory);

  static T _acquire<T extends BlocBase>(String k, T Function() factory) {
    final existing = _instances[k];
    if (existing == null || (existing as dynamic).isClosed) {
      final effectiveFactory = (_overrides[k] ?? factory) as T Function();
      _instances[k] = effectiveFactory();
      _refCounts[k] = 0;
      Logger.debug('BlocManager: created $k (total: ${_instances.length})');
    }
    _refCounts[k] = (_refCounts[k] ?? 0) + 1;
    return _instances[k] as T;
  }

  // ── Test overrides ────────────────────────────────────────────

  /// Override một BLoC/Cubit bằng mock — dùng trong test setUp.
  /// Gọi [clearTestOverrides] trong tearDown để dọn sạch.
  ///
  /// ```dart
  /// setUp(() => BlocManager.addOverride<ProductCubit>(() => MockProductCubit()));
  /// tearDown(BlocManager.clearTestOverrides);
  /// ```
  static void addOverride<T extends BlocBase>(T Function() factory, {String? key}) {
    _overrides[_key<T>(key)] = factory;
  }

  static void clearTestOverrides() => _overrides.clear();

  // ── Release ───────────────────────────────────────────────────

  /// Giảm refCount. Tự close và xóa khi refCount = 0.
  static void release<T extends BlocBase>({String? key}) {
    final k = _key<T>(key);
    final count = _refCounts[k];
    if (count == null) return;

    if (count <= 1) {
      _closeAndRemove(k);
    } else {
      _refCounts[k] = count - 1;
    }
  }

  // ── Peek ──────────────────────────────────────────────────────

  /// Đọc instance hiện tại mà KHÔNG tăng refCount.
  /// Trả về null nếu chưa tạo hoặc đã closed.
  static T? peek<T extends BlocBase>({String? key}) {
    final k = _key<T>(key);
    final bloc = _instances[k];
    if (bloc == null) return null;
    if ((bloc as dynamic).isClosed) {
      _closeAndRemove(k);
      return null;
    }
    return bloc as T;
  }

  // ── Recreate ──────────────────────────────────────────────────

  /// Buộc tạo lại từ GetIt — giữ nguyên refCount.
  /// Dùng khi cần reset state mà không ảnh hưởng widget đang mount.
  static T recreate<T extends BlocBase>({String? key}) =>
      _recreateInternal<T>(_key<T>(key), () => getIt<T>());

  /// Buộc tạo lại bằng factory — dùng khi cần truyền params mới.
  ///
  /// ```dart
  /// BlocManager.recreateWith<DetailCubit>(
  ///   () => DetailCubit(id: newId),
  ///   key: 'detail_$newId',
  /// );
  /// ```
  static T recreateWith<T extends BlocBase>(T Function() factory, {String? key}) =>
      _recreateInternal<T>(_key<T>(key), factory);

  static T _recreateInternal<T extends BlocBase>(String k, T Function() factory) {
    final currentRef = _refCounts[k] ?? 1;
    final old = _instances[k];
    if (old != null && !(old as dynamic).isClosed) old.close();
    _instances[k] = factory();
    _refCounts[k] = currentRef;
    Logger.debug('BlocManager: recreated $k');
    return _instances[k] as T;
  }

  // ── Dispose all ───────────────────────────────────────────────

  /// Hủy tất cả — dùng khi logout hoặc reset app.
  static void disposeAll() {
    for (final k in _instances.keys.toList()) {
      _closeAndRemove(k);
    }
    Logger.debug('BlocManager: disposed ALL');
  }

  // ── Debug ─────────────────────────────────────────────────────

  static void debugPrint() {
    Logger.debug('╔══ BlocManager (${_instances.length} active) ══');
    for (final k in _instances.keys) {
      final closed = (_instances[k] as dynamic).isClosed;
      Logger.debug('║ $k — refs: ${_refCounts[k]} — closed: $closed');
    }
    Logger.debug('╚════════════════════════════════════');
  }

  // ── Internal ──────────────────────────────────────────────────

  static void _closeAndRemove(String k) {
    final bloc = _instances.remove(k);
    _refCounts.remove(k);
    if (bloc != null && !(bloc as dynamic).isClosed) bloc.close();
    Logger.debug('BlocManager: disposed $k (remaining: ${_instances.length})');
  }
}
