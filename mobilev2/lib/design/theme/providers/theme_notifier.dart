import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/data/storage/local_storage_service.dart';
import 'package:karaoke/design/theme/app_theme.dart';
import 'package:karaoke/design/theme/providers/theme_state.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_notifier.g.dart';

const _kThemeColor = 'theme_color';
const _kThemeMode = 'theme_mode';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  LocalStorageService get _storage => getIt<LocalStorageService>();

  @override
  ThemeState build() {
    return ThemeState(
      palette: _parseEnum(
        AppPalette.values,
        _storage.getString(_kThemeColor),
        fallback: AppPalette.light,
      ),
      themeMode: _parseEnum(
        AppThemeMode.values,
        _storage.getString(_kThemeMode),
        fallback: AppThemeMode.light,
      ),
    );
  }

  Future<void> changePalette(AppPalette palette) async {
    await _storage.setString(_kThemeColor, palette.name);
    state = state.copyWith(palette: palette);
  }

  Future<void> changeMode(AppThemeMode mode) async {
    await _storage.setString(_kThemeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> toggleTheme() =>
      changeMode(state.isDark ? AppThemeMode.light : AppThemeMode.dark);

  T _parseEnum<T extends Enum>(List<T> values, String? value, {required T fallback}) =>
      values.firstWhere((e) => e.name == value, orElse: () => fallback);
}
