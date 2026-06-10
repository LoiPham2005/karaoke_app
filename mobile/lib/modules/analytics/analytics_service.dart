import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:injectable/injectable.dart';

import '../../core/common/utils/logger.dart';

@LazySingleton()
class AnalyticsService {
  final _fa = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver? _observer;

  FirebaseAnalyticsObserver get observer =>
      _observer ??= FirebaseAnalyticsObserver(analytics: _fa);

  // ─── User ─────────────────────────────────────────────────────

  Future<void> setUserId(String? id) =>
      _fa.setUserId(id: id).catchError((e) => _err('setUserId', e));

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) => _fa
      .setUserProperty(name: name, value: value)
      .catchError((e) => _err('setUserProperty', e));

  Future<void> setUserDemographics({
    String? age,
    String? gender,
    String? country,
    String? language,
  }) async {
    if (age != null) await setUserProperty(name: 'age', value: age);
    if (gender != null) await setUserProperty(name: 'gender', value: gender);
    if (country != null) await setUserProperty(name: 'country', value: country);
    if (language != null) {
      await setUserProperty(name: 'language', value: language);
    }
  }

  // ─── Screen ───────────────────────────────────────────────────

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _fa.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      if (parameters != null && parameters.isNotEmpty) {
        await logEvent(
          name: 'screen_view_detailed',
          parameters: {'screen_name': screenName, ...parameters},
        );
      }
      if (kDebugMode) Logger.info('📱 Screen: $screenName', tag: 'ANALYTICS');
    } catch (e) {
      _err('logScreenView', e);
    }
  }

  // ─── Events ───────────────────────────────────────────────────

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final n = _sanitizeName(name);
      final p = _sanitizeParams(parameters);
      await _fa.logEvent(name: n, parameters: p);
      if (kDebugMode) Logger.info('📊 $n ${p ?? ""}', tag: 'ANALYTICS');
    } catch (e) {
      _err('logEvent:$name', e);
    }
  }

  // ─── App lifecycle ────────────────────────────────────────────

  Future<void> logAppOpen() => logEvent(
    name: 'app_open',
    parameters: {
      'flavor': FlavorConfig.flavor.name,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  Future<void> logAppBackground() => logEvent(name: 'app_background');
  Future<void> logAppResume() => logEvent(name: 'app_resume');

  // ─── Business ─────────────────────────────────────────────────

  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    String? itemName,
    Map<String, dynamic>? parameters,
  }) => _fa.logPurchase(
    currency: currency,
    value: value,
    transactionId: transactionId,
    parameters: {'item_name': ?itemName, ...?parameters},
  );

  Future<void> logInAppPurchase({
    required String productId,
    required String productName,
    required double price,
    required String currency,
  }) => logEvent(
    name: 'in_app_purchase',
    parameters: {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'currency': currency,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  /// GA4 ad revenue event — used by AdAnalyticsTracker.trackAdRevenuePaid().
  Future<void> logAdRevenuePaid({
    required double value,
    required String currency,
    required String adPlatform,
    required String adSource,
    required String adUnitName,
    required String adFormat,
  }) => logEvent(
    name: 'ad_revenue',
    parameters: {
      'value': value,
      'currency': currency,
      'ad_platform': adPlatform,
      'ad_source': adSource,
      'ad_unit_name': adUnitName,
      'ad_format': adFormat,
    },
  );

  // ─── Engagement ───────────────────────────────────────────────

  Future<void> logButtonClick({
    required String buttonName,
    String? screenName,
    Map<String, dynamic>? params,
  }) => logEvent(
    name: 'button_click',
    parameters: {
      'button_name': buttonName,
      'screen_name': ?screenName,
      ...?params,
    },
  );

  Future<void> logFeatureUsage({
    required String featureName,
    Map<String, dynamic>? params,
  }) => logEvent(
    name: 'feature_usage',
    parameters: {'feature_name': featureName, ...?params},
  );

  Future<void> logSearch({required String searchTerm, String? category}) =>
      _fa.logSearch(
        searchTerm: searchTerm,
        parameters: category != null ? {'category': category} : null,
      );

  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) => _fa.logShare(
    contentType: contentType,
    itemId: itemId,
    method: method ?? '',
  );

  // ─── Errors ───────────────────────────────────────────────────

  Future<void> logError({
    required String errorName,
    String? errorMessage,
    String? stackTrace,
    Map<String, dynamic>? parameters,
  }) => logEvent(
    name: 'app_error',
    parameters: {
      'error_name': errorName,
      'error_message': ?errorMessage,
      if (stackTrace != null && stackTrace.isNotEmpty)
        'stack_trace': stackTrace.length > 100
            ? stackTrace.substring(0, 100)
            : stackTrace,
      ...?parameters,
    },
  );

  // ─── Utilities ────────────────────────────────────────────────

  Future<void> resetAnalyticsData() =>
      _fa.resetAnalyticsData().catchError((e) => _err('resetAnalyticsData', e));

  Future<void> setAnalyticsCollectionEnabled(bool enabled) => _fa
      .setAnalyticsCollectionEnabled(enabled)
      .catchError((e) => _err('setAnalyticsCollection', e));

  // ─── Private ──────────────────────────────────────────────────

  /// Firebase: name ≤40 chars, alphanumeric + underscore, starts with letter.
  String _sanitizeName(String name) {
    var s = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (!s.startsWith(RegExp(r'[a-z]'))) s = 'e_$s';
    return s.length > 40 ? s.substring(0, 40) : s;
  }

  /// Firebase: ≤25 params, keys ≤40 chars, string values ≤100 chars.
  Map<String, Object>? _sanitizeParams(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return null;
    final result = <String, Object>{};
    for (final e in params.entries.take(25)) {
      if (e.value == null) continue;
      var k = e.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      if (k.length > 40) k = k.substring(0, 40);
      final v = e.value;
      result[k] = (v is num || v is bool)
          ? v
          : (v.toString().length > 100
                ? v.toString().substring(0, 100)
                : v.toString());
    }
    return result.isEmpty ? null : result;
  }

  void _err(String method, Object e) =>
      Logger.error('Analytics.$method failed', error: e, tag: 'ANALYTICS');
}
