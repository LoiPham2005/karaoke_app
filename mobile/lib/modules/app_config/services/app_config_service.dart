import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/core/base/di/injection.dart';
import 'package:injectable/injectable.dart';

import '../models/app_config.dart';
import '../utils/app_config_defaults.dart';

const _kAppConfigKey = 'app_config';

AppConfigService get appConfigService => getIt<AppConfigService>();

@lazySingleton
class AppConfigService {
  AppConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  final ValueNotifier<AppConfig> config = ValueNotifier(
    (!kUseAppRemoteConfig || kDebugMode) ? kAppConfigDev : kAppConfigDisabled,
  );

  AppConfig get current => config.value;

  /// Gọi 1 lần khi app khởi động (sau Firebase.initializeApp).
  Future<void> initialize() async {
    if (!kUseAppRemoteConfig) {
      debugPrint('[AppConfigService] kUseAppRemoteConfig=false → dùng kAppConfigDev');
      config.value = kAppConfigDev;
      return;
    }

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      _kAppConfigKey: jsonEncode(kAppConfigDisabled.toJson()),
    });

    await _fetchAndActivate();

    _remoteConfig.onConfigUpdated.listen((_) async {
      await _remoteConfig.activate();
      _updateConfig();
    });
  }

  Future<void> _fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      debugPrint(
        '[AppConfigService] fetchAndActivate → activated=$activated, '
        'lastFetchStatus=${_remoteConfig.lastFetchStatus}',
      );
    } catch (e) {
      debugPrint('[AppConfigService] fetchAndActivate failed: $e');
    }
    _updateConfig();
  }

  void _updateConfig() {
    if (!kUseAppRemoteConfig) {
      config.value = kAppConfigDev;
      return;
    }
    final raw = _remoteConfig.getString(_kAppConfigKey);
    final source = _remoteConfig.getValue(_kAppConfigKey).source;
    debugPrint('[AppConfigService] raw (source=$source): $raw');
    config.value = _parse(raw);
    _logConfig(config.value);
  }

  AppConfig _parse(String raw) {
    if (raw.isEmpty) return kAppConfigDisabled;
    try {
      return AppConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[AppConfigService] parse error: $e');
      return kAppConfigDisabled;
    }
  }

  void _logConfig(AppConfig cfg) {
    debugPrint('[AppConfigService] === APP CONFIG UPDATED ===');
    debugPrint('[AppConfigService] latestVersion=${cfg.latestVersion} | minVersion=${cfg.minVersion}');
    debugPrint('[AppConfigService] noticeEnabled=${cfg.noticeEnabled} | maintenance=${cfg.maintenance}');
    if (cfg.noticeEnabled) {
      debugPrint('[AppConfigService] notice: "${cfg.noticeTitle}" — ${cfg.noticeBody}');
    }
  }
}
