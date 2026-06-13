import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/design/theme/app_theme.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';

part 'theme_state.freezed.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(AppPalette.light) AppPalette palette,
    @Default(AppThemeMode.light) AppThemeMode themeMode,
  }) = _ThemeState;

  const ThemeState._();

  // ✅ Helper getters
  bool get isDark => themeMode == AppThemeMode.dark;
  bool get isLight => themeMode == AppThemeMode.light;
  bool get isSystem => themeMode == AppThemeMode.system;

  /// Map custom theme mode to Flutter Material ThemeMode
  ThemeMode get materialThemeMode => switch (themeMode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
}
