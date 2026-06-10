import 'package:flutter/material.dart';
import 'package:flutter_base/core/data/storage/local/local_storage_keys.dart';
import 'package:flutter_base/core/data/storage/local/local_storage_service.dart';
import 'package:flutter_base/gen/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storageService) : super(defaultLocale);

  final LocalStorageService _storageService;

  /// Ngôn ngữ mặc định của ứng dụng.
  static const Locale defaultLocale = Locale('vi');

  /// Tên hiển thị cho mỗi ngôn ngữ được hỗ trợ.
  /// Nguồn sự thật: [AppLocalizations.supportedLocales] (gen từ ARB).
  static const Map<String, String> languageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'fr': 'Français',
    'zh': '简体中文',
  };

  /// Kiểm tra languageCode có được hỗ trợ không — dựa vào AppLocalizations.
  bool _isSupported(String languageCode) {
    return AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == languageCode,
    );
  }

  /// Khởi tạo locale: ưu tiên locale đã lưu → locale hệ thống → mặc định.
  Future<void> initLocale() async {
    try {
      final savedLocale = _storageService.get<String>(
        LocalStorageKeys.languageCode,
      );

      if (savedLocale != null && _isSupported(savedLocale)) {
        emit(Locale(savedLocale));
        return;
      }

      // Tự động detect ngôn ngữ của thiết bị
      final systemLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (_isSupported(systemLocale)) {
        await changeLocale(systemLocale);
      } else {
        emit(defaultLocale);
      }
    } catch (_) {
      emit(defaultLocale);
    }
  }

  /// Thay đổi ngôn ngữ và lưu vào local storage.
  Future<void> changeLocale(String languageCode) async {
    if (!_isSupported(languageCode)) return;

    final newLocale = Locale(languageCode);
    if (newLocale == state) return;

    await _storageService.set(LocalStorageKeys.languageCode, languageCode);
    emit(newLocale);
  }

  /// Tên hiển thị của ngôn ngữ hiện tại.
  String get currentLanguageName =>
      languageNames[state.languageCode] ?? state.languageCode;

  /// Ngôn ngữ hiện tại có phải RTL không.
  bool get isRTL => const {'ar', 'fa', 'he', 'ur'}.contains(state.languageCode);
}
