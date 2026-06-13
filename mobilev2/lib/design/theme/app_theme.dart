// 📁 lib/design/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:karaoke/design/theme/providers/theme_state.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/gen/fonts.gen.dart';

enum AppThemeMode { light, dark, system }

class AppTheme {
  AppTheme._();

  static List<AppPalette> get allThemes => AppPalette.values;

  static ThemeData light(ThemeState state) =>
      build(palette: state.palette, brightness: Brightness.light);

  static ThemeData dark(ThemeState state) =>
      build(palette: state.palette, brightness: Brightness.dark);

  static ThemeData build({required AppPalette palette, required Brightness brightness}) {
    final tokens = palette.tokens;
    final colorScheme = _buildScheme(tokens, brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bgPage,
      fontFamily: FontFamily.inter,
      extensions: [tokens],
    );
  }

  /// Map custom tokens → Material3 ColorScheme
  static ColorScheme _buildScheme(AppColorTokens t, Brightness b) => ColorScheme(
    brightness: b,
    primary: t.brandPrimary,
    onPrimary: t.textOnPrimary,
    secondary: t.brandSecondary,
    onSecondary: t.textOnPrimary,
    surface: t.bgCard,
    onSurface: t.textTitle,
    error: t.statusError,
    onError: Colors.white,
    outline: t.borderDefault,
    shadow: t.surfaceShadow,
  );
}
