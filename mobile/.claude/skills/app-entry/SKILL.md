---
name: app-entry
description: App entry points — app.dart, main_common, main_dev/stg/prod, AppRouter, error zone setup. Dùng khi làm việc với khởi chạy app, cấu hình runApp, provider gốc, hoặc xử lý lỗi global.
when_to_use: Trigger khi user hỏi về app.dart, main entry, MultiBlocProvider root, global error handling, ScreenUtil, FlutterSmartDialog setup, AppRouter.
user-invocable: false
allowed-tools: Read Glob Grep
---

# App Entry Points

## Entry Points theo flavor

```
lib/main_dev.dart   → FlavorConfig.setFlavor(AppFlavor.dev)  → runMainApp()
lib/main_stg.dart   → FlavorConfig.setFlavor(AppFlavor.stg)  → runMainApp()
lib/main_prod.dart  → FlavorConfig.setFlavor(AppFlavor.prod) → runMainApp()
```

Cả 3 file gọi chung `runMainApp()` từ `lib/main_common.dart`.

---

## main_common.dart — Startup & Error Handling

```dart
void runMainApp() {
  // 1. Bắt mọi lỗi async trong zone
  runZonedGuarded(() async {

    WidgetsFlutterBinding.ensureInitialized();

    // 2. Bắt lỗi Flutter UI/framework
    FlutterError.onError = (details) {
      CrashlyticsService.instance.recordFlutterError(details); // prod/stg
    };

    // 3. Bắt lỗi platform/native
    PlatformDispatcher.instance.onError = (error, stack) {
      CrashlyticsService.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await AppInitializer.initialize(); // 5 phases
    runApp(const App());

  }, (error, stack) {
    CrashlyticsService.instance.recordError(error, stack);
  });
}
```

**3 lớp bắt lỗi:**
1. `runZonedGuarded` → lỗi async zone (Future, stream không được handle)
2. `FlutterError.onError` → lỗi render/layout/framework
3. `PlatformDispatcher.instance.onError` → lỗi native, fatal = true

---

## app.dart — Root Widget

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),   // iPhone 13 base design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<LocaleCubit>()),
            BlocProvider(create: (_) => getIt<ThemeCubit>()),
            BlocProvider(create: (_) => getIt<AppAuthCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp.router(
                    title: AppConstants.appName,
                    theme: AppTheme.light(themeState.colorTheme),
                    darkTheme: AppTheme.dark(themeState.colorTheme),
                    themeMode: themeState.themeMode,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    routerConfig: AppRouter.router,
                    builder: FlutterSmartDialog.init(builder: (ctx, child) => child!),
                    debugShowCheckedModeBanner: FlavorConfig.isDev,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
```

**3 provider ở root (luôn có mặt):**
| Provider | Mô tả |
|---|---|
| `LocaleCubit` | Ngôn ngữ app (vi/en/ko/...) |
| `ThemeCubit` | Theme mode + color palette |
| `AppAuthCubit` | Trạng thái auth global |

---

## AppRouter (`lib/routes/`)

```dart
// GoRouter với NavigationObserver cho Analytics
final router = GoRouter(
  navigatorKey: getIt<NavigationService>().navigatorKey,
  observers: [getIt<AnalyticsService>().observer],
  redirect: (context, state) => RouteGuards.redirect(context, state),
  routes: [...],
);
```

**Route guards** (`lib/routes/guards/route_guards.dart`):
- Đọc `AppAuthCubit` → redirect về `/login` nếu unauthenticated
- `_publicRoutes` list → bỏ qua guard cho login, splash, onboarding

---

## ScreenUtil

Design base size: `375 × 812` (iPhone 13).

```dart
// Responsive sizing trong widget
16.w    // width-proportional
16.h    // height-proportional
16.r    // radius-proportional
16.sp   // font size-proportional
```

---

## FlutterSmartDialog

Được init trong `MaterialApp.router` builder. Sau đó dùng qua `ToastService`:

```dart
toast.success('...');
toast.loading('...');
toast.dismiss();
```

Không gọi `SmartDialog.*` trực tiếp — dùng `ToastService`.
