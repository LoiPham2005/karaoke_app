import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/modules/ads/models/ad_config.dart';
import 'package:flutter_base/modules/ads/utils/ad_defaults.dart';
import 'package:injectable/injectable.dart';

/// Key trong Firebase Remote Config.
const _kAdConfigKey = 'ad_config';

@lazySingleton
class AdConfigService {
  AdConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  // Expose ra ValueNotifier để widget có thể lắng nghe realtime.
  // final ValueNotifier<AdConfig> config = ValueNotifier(AdConfig.disabled());

  // Dev mode hoặc khi tắt Remote Config sẽ dùng test IDs, ngược lại bắt đầu với disabled.
  final ValueNotifier<AdConfig> config = ValueNotifier(
    (!kUseRemoteConfig || kDebugMode) ? AdConfig.development() : AdConfig.disabled(),
  );

  /// Gọi 1 lần khi app khởi động (sau Firebase.initializeApp).
  Future<void> initialize() async {
    if (!kUseRemoteConfig) {
      Logger.info('kUseRemoteConfig=false → dùng AdConfig.development()', tag: 'ADS CONFIG');
      _updateConfig();
      return;
    }

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );

    // Giá trị mặc định khi chưa fetch được — tắt ads.
    await _remoteConfig.setDefaults({_kAdConfigKey: jsonEncode(AdConfig.disabled().toJson())});

    await _fetchAndActivate();

    // Lắng nghe thay đổi realtime (Remote Config Realtime).
    _remoteConfig.onConfigUpdated.listen((_) async {
      await _remoteConfig.activate();
      _updateConfig();
    });
  }

  Future<void> _fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      Logger.info(
        'fetchAndActivate → activated=$activated | '
        'status=${_remoteConfig.lastFetchStatus} | '
        'lastFetch=${_remoteConfig.lastFetchTime}',
        tag: 'ADS CONFIG',
      );
    } catch (e) {
      Logger.error('fetchAndActivate failed', error: e, tag: 'ADS CONFIG');
    }
    _updateConfig();
  }

  void _updateConfig() {
    if (!kUseRemoteConfig) {
      config.value = AdConfig.development();
      _logConfig(config.value);
      return;
    }

    final raw = _remoteConfig.getString(_kAdConfigKey);
    final source = _remoteConfig.getValue(_kAdConfigKey).source;
    Logger.info('source=$source | length=${raw.length} chars', tag: 'ADS CONFIG');

    final parsed = _parse(raw);
    if (!parsed.useRemoteConfig) {
      Logger.info('useRemoteConfig=false → dùng AdConfig.development()', tag: 'ADS CONFIG');
      config.value = AdConfig.development();
      _logConfig(config.value);
      return;
    }
    config.value = parsed;
  }

  AdConfig _parse(String raw) {
    if (raw.isEmpty) return AdConfig.disabled();
    try {
      final cfg = AdConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _logConfig(cfg);
      return cfg;
    } catch (e) {
      Logger.error('parse failed → fallback disabled', error: e, tag: 'ADS CONFIG');
      return AdConfig.disabled();
    }
  }

  void _logConfig(AdConfig cfg) {
    final rows = <(String, String)>[];

    // Header flags
    rows.add(('showAllAds', '${cfg.showAllAds}'));
    rows.add(('enableInter', '${cfg.enableInter}'));
    rows.add(('enableAppOpen', '${cfg.enableAppOpen}'));
    rows.add(('enableRewarded', '${cfg.enableRewarded}'));
    rows.add(('enableNative', '${cfg.enableNative}'));
    rows.add(('enableNativeFull', '${cfg.enableNativeFull}'));
    rows.add(('enableBanner', '${cfg.enableBanner}'));
    rows.add(('nativeFullAfterInter', '${cfg.nativeFullAfterInter}'));
    rows.add(('totalPlacements', '${cfg.totalPlacements}'));
    rows.add(('interInterval', '${cfg.rules.interInterval}s'));
    rows.add(('maxInterPerSession', '${cfg.rules.maxInterPerSession}'));

    // Placements theo group
    void addGroup(String type, Map<String, AdUnit> units) {
      if (units.isEmpty) return;
      rows.add(('── $type (${units.length})', ''));
      for (final e in units.entries) {
        final u = e.value;
        final status = u.enable ? '✅ ON' : '❌ OFF';
        final activeId = (u.useId2 == true && u.id2.isNotEmpty) ? u.id2 : u.id;
        final idLine = u.id2.isNotEmpty
            ? 'id=${u.id} | id2=${u.id2} | useId2=${u.useId2 ?? 'null(follow global)'} → $activeId'
            : u.id;
        rows.add(('  ${e.key}', '$status  $idLine'));
      }
    }

    addGroup('inter', cfg.inter);
    addGroup('app_open', cfg.appOpen);
    addGroup('rewarded', cfg.rewarded);
    addGroup('native', cfg.native);
    addGroup('banner', cfg.banner);

    Logger.adTable('Config Updated', tag: 'ADS CONFIG', rows: rows);
  }

  AdConfig get current => config.value;
}
