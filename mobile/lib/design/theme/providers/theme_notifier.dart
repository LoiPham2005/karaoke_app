import 'package:flutter_base/core/data/storage/local/local_storage_provider.dart';
import 'package:flutter_base/design/theme/app_theme.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'theme_state.dart';

part 'theme_notifier.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    final storage = ref.watch(localStorageServiceProvider);
    return ThemeState(
      palette: _parseEnum(AppPalette.values, storage.getThemeColor(), fallback: AppPalette.light),
      themeMode: _parseEnum(
        AppThemeMode.values,
        storage.getThemeMode(),
        fallback: AppThemeMode.light,
      ),
    );
  }

  Future<void> changePalette(AppPalette palette) async {
    await ref.read(localStorageServiceProvider).saveThemeColor(palette.name);
    state = state.copyWith(palette: palette);
  }

  Future<void> changeMode(AppThemeMode mode) async {
    await ref.read(localStorageServiceProvider).saveThemeMode(mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> toggleTheme() => changeMode(state.isDark ? AppThemeMode.light : AppThemeMode.dark);

  T _parseEnum<T extends Enum>(List<T> values, String? value, {required T fallback}) =>
      values.firstWhere((e) => e.name == value, orElse: () => fallback);
}
