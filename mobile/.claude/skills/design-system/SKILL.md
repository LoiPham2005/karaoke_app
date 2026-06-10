---
name: design-system
description: Design system — Colors, Dimensions, TextStyles, AppTheme, ThemeCubit, LocaleCubit. Dùng khi làm việc với màu sắc, kích thước, typography, dark mode, đa ngôn ngữ, token màu.
when_to_use: Trigger khi user hỏi về màu, font, spacing, theme, dark mode, ngôn ngữ, locale, l10n, color token, AppDimensions.
user-invocable: false
allowed-tools: Read Glob Grep
---

# Design System — `lib/design/`

```
lib/design/
  theme/
    styles/
      app_colors.dart        — Static color constants
      app_dimensions.dart    — Spacing, radius, icon sizes
      app_text_styles.dart   — Typography scale + extensions
    app_theme.dart           — AppTheme.light() / AppTheme.dark()
    cubit/
      theme_cubit.dart       — ThemeCubit, ThemeState
  l10n/
    cubit/
      locale_cubit.dart      — LocaleCubit
    translations/
      app_en.arb, app_vi.arb, ... — Chuỗi dịch
```

---

## AppColors (`styles/app_colors.dart`)

```dart
// Static (không đổi theo theme)
AppColors.white
AppColors.black
AppColors.transparent
AppColors.facebook    // #1877F2
AppColors.google      // #4285F4

// Semantic (dùng qua ThemeExtension — tự động đổi theo theme)
AppColors.textPrimary
AppColors.textSecondary
AppColors.textHint
AppColors.textDisabled
AppColors.success
AppColors.warning
AppColors.error
AppColors.info
AppColors.grey / greyLight / greyDark
```

> Nếu màu cần đổi theo light/dark: dùng `Theme.of(context).colorScheme.*` hoặc token từ `AppColorPalettes`.

---

## AppDimensions (`styles/app_dimensions.dart`)

```dart
// Spacing
AppDimensions.padding       // 16
AppDimensions.margin        // 16
AppDimensions.gap           // 12
AppDimensions.gapSmall      // 8

// Border Radius
AppDimensions.radius        // 12
AppDimensions.radiusSmall   // 8
AppDimensions.radiusLarge   // 20
AppDimensions.circle        // 999

// Widget
AppDimensions.icon          // 24
AppDimensions.iconSmall     // 20
AppDimensions.buttonHeight  // 48

// Elevation
AppDimensions.elevation0    // 0
AppDimensions.elevation1    // 1
AppDimensions.elevation2    // 2
AppDimensions.elevation4    // 4

// Breakpoints
AppDimensions.mobile        // 600
AppDimensions.tablet        // 900
AppDimensions.desktop       // 1200
```

> Tất cả giá trị responsive — sử dụng `.w`, `.h`, `.r`, `.sp` từ ScreenUtil khi cần thiết.

---

## AppTextStyles (`styles/app_text_styles.dart`)

**Font family:** Inter

```dart
// Size scale (line height 1.5)
AppTextStyles.s10 / s12 / s14 / s16 / s18 / s20 / s24 / s28 / s32

// Extension chain
AppTextStyles.s16.semiBold          // FontWeight.w600
AppTextStyles.s14.medium.italic     // w500 + italic
AppTextStyles.s20.bold.underline

// Weight extensions
.w100 / .w200 / .w300 ... .w900
.light (.w300)
.regular (.w400)
.medium (.w500)
.semiBold (.w600)
.bold (.w700)
.extraBold (.w800)
.blackWeight (.w900)

// Style extensions
.italic
.underline
.lineThrough
.overline

// Color extensions
.error     // AppColors.error
.success
.warning
.info
.grey
.textHint
.textSecondary
.withScheme(context)   // dùng colorScheme.onSurface (theme-aware)
```

**Ví dụ:**
```dart
Text('Hello', style: AppTextStyles.s16.semiBold.withScheme(context))
Text('Error', style: AppTextStyles.s14.medium.error)
```

---

## AppTheme (`app_theme.dart`)

```dart
// Tạo ThemeData
AppTheme.light(colorTheme)   // Material3 light
AppTheme.dark(colorTheme)    // Material3 dark

// colorTheme: AppColorTheme enum — palette đã định nghĩa trong color_config.json
```

---

## ThemeCubit (`cubit/theme_cubit.dart`)

```dart
// State: ThemeState { AppThemeMode mode, AppColorTheme colorTheme }

// Khởi tạo (gọi trong AppInitializer Phase 5)
await ThemeCubit.initTheme();

// Trong widget (qua BlocProvider root)
context.read<ThemeCubit>().toggleTheme();
context.read<ThemeCubit>().changeMode(AppThemeMode.dark);
context.read<ThemeCubit>().changeColor(AppColorTheme.blue);

// Getter
context.read<ThemeCubit>().isDarkMode    // bool
context.read<ThemeCubit>().currentColor  // AppColorTheme
context.read<ThemeCubit>().currentMode   // AppThemeMode
```

**AppThemeMode:**
```dart
enum AppThemeMode { light, dark, system }
```

---

## LocaleCubit (`l10n/cubit/locale_cubit.dart`)

```dart
// State: Locale

// Supported: vi, en, ko, ja, fr, zh

// Khởi tạo (gọi trong AppInitializer Phase 5)
await LocaleCubit.initLocale();

// Đổi ngôn ngữ
context.read<LocaleCubit>().changeLocale('en');

// Getter
context.read<LocaleCubit>().currentLanguageName  // "Tiếng Việt"
context.read<LocaleCubit>().isRTL                 // false (vi/en không RTL)
```

**Dùng trong widget:**
```dart
// Extension (xem core-architecture skill)
context.l10n.someKey

// Trực tiếp
AppLocalizations.of(context)!.someKey
```

---

## Localization files (`l10n/translations/`)

Source: `app_en.arb` → sync bằng `make l10n_sync`.

```
app_en.arb  — Source (English)
app_vi.arb  — Vietnamese
app_ko.arb  — Korean
app_ja.arb  — Japanese
app_fr.arb  — French
app_zh.arb  — Chinese
```

**Thêm chuỗi mới:**
1. Thêm vào `app_en.arb`
2. Chạy `make l10n_sync` → tự động dịch các ngôn ngữ còn lại
3. Chạy `make l10n` → gen code

---

## Color Token System (`lib/gen/theme/`)

Generated từ `lib/design/theme/colors/color_config.json` bởi `tools/theme_gen.dart`.

```dart
// color_tokens.dart — semantic token names
AppColorTokens.primary
AppColorTokens.background
AppColorTokens.surface
// ...

// color_palettes.dart — light/dark values cho từng token
AppColorPalettes.light   // Map<AppColorToken, Color>
AppColorPalettes.dark
```

> Sửa màu: chỉnh `color_config.json` → chạy `make theme-gen`.

---

## Responsive Widgets (`lib/shared/widgets/responsive/`)

```dart
// Build khác nhau theo screen size
ResponsiveBuilder(
  mobile: (ctx) => MobileLayout(),
  tablet: (ctx) => TabletLayout(),
  desktop: (ctx) => DesktopLayout(),
)

// Lấy giá trị responsive
final padding = ResponsiveValue<double>(
  context,
  mobile: 16,
  tablet: 24,
  desktop: 32,
).value;

// Grid tự động điều chỉnh cột
ResponsiveGrid(
  children: [...],
  // mobile: 2 cols, tablet: 3 cols, desktop: 4 cols
)
```
