import 'package:flutter/material.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/data/storage/local_storage_service.dart';
import 'package:karaoke/gen/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_notifier.g.dart';

const _kLanguageCode = 'language_code';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const Locale defaultLocale = Locale('vi');

  static const Map<String, String> languageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'fr': 'Français',
    'zh': '简体中文',
  };

  LocalStorageService get _storage => getIt<LocalStorageService>();

  @override
  Locale build() {
    final saved = _storage.getString(_kLanguageCode);
    if (saved != null && _isSupported(saved)) return Locale(saved);

    final system = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (_isSupported(system)) return Locale(system);

    return defaultLocale;
  }

  Future<void> changeLocale(String languageCode) async {
    if (!_isSupported(languageCode)) return;
    final newLocale = Locale(languageCode);
    if (newLocale == state) return;
    await _storage.setString(_kLanguageCode, languageCode);
    state = newLocale;
  }

  bool _isSupported(String languageCode) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == languageCode);

  String get currentLanguageName =>
      languageNames[state.languageCode] ?? state.languageCode;

  bool get isRTL => const {'ar', 'fa', 'he', 'ur'}.contains(state.languageCode);
}
