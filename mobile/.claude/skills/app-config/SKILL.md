---
name: app-config
description: Cấu trúc khởi tạo và cấu hình app — Flavor, AppInitializer, AppStartup, Env, Observers, SystemUI. Dùng khi làm việc với main.dart, splash screen, khởi tạo service, thêm service mới vào startup, hoặc config theo môi trường.
when_to_use: Trigger khi user hỏi về flavor/env, thứ tự khởi tạo app, thêm service mới, cấu hình môi trường dev/stg/prod, observer lifecycle, system UI.
user-invocable: true
allowed-tools: Read Edit Glob
---

# App Configuration — `lib/config/`

```
lib/config/
  app/
    flavor_config.dart    — Singleton quản lý môi trường (dev/stg/prod)
    app_initializer.dart  — Entry point khởi tạo toàn bộ app (gọi từ main)
    app_startup.dart      — Logic sau init, chạy từ SplashScreen
  env/
    env_dev.dart          — Envied config cho DEV  (hiện commented-out)
    env_stg.dart          — Envied config cho STG  (hiện commented-out)
    env_prod.dart         — Envied config cho PROD (hiện commented-out)
  observers/
    app_bloc_observer.dart — Log event/state/error của BLoC (dev/stg only)
    app_observer.dart      — Monitor app lifecycle (resume/pause/detach)
  ui/
    system_ui_manager.dart — Singleton: orientation lock, status bar, nav bar
```

---

## FlavorConfig (`app/flavor_config.dart`)

Singleton, set **1 lần duy nhất** trong `main_*.dart`.

```dart
enum AppFlavor { dev, stg, prod }

// Trong main_dev.dart
FlavorConfig.setFlavor(AppFlavor.dev);

// Check môi trường
FlavorConfig.isDev    // bool
FlavorConfig.isStg    // bool
FlavorConfig.isProd   // bool

// API config (đọc từ ApiConstants theo flavor)
FlavorConfig.apiBaseUrl       // String
FlavorConfig.webSocketUrl     // String
FlavorConfig.connectTimeout   // Duration
FlavorConfig.receiveTimeout   // Duration

// Feature flags
FlavorConfig.enableLogging        // dev: true, stg: true, prod: false
FlavorConfig.enableDebugTools     // dev: true, stg: false, prod: false
FlavorConfig.enableAnalytics      // dev: false, stg: true,  prod: true
FlavorConfig.enableCrashReporting // dev: false, stg: true,  prod: true

// API Keys
FlavorConfig.googleMapsApiKey
FlavorConfig.stripePublicKey
```

> Config thực tế nằm trong `lib/core/common/constants/api_constants.dart`

---

## AppInitializer — Thứ tự khởi tạo (`app/app_initializer.dart`)

Gọi từ `main_*.dart` trước khi `runApp()`.

```
Phase 0: Firebase.initializeApp() + CrashlyticsService.initialize()
Phase 1: FlavorConfig.printInfo()
         LoggerConfig.configure()
         SystemUIManager.initialize()       ← orientation lock, status/nav bar
         AppObserver.initialize()           ← app lifecycle observer
         _configureBlocObserver()           ← AppBlocObserver (dev/stg only)
Phase 2: configureDependencies()            ← injectable + get_it
Phase 3: AdConfigService.initialize()
         AdManager.initialize()
         AdLifecycleObserver.init()
Phase 4: CacheService.initialize()
Phase 5: Future.wait([
           ThemeCubit.initTheme(),
           LocaleCubit.initLocale(),
           AppAuthCubit.checkAuthStatus(),
           NotificationService.initialize(),
         ])
         IapService.initialize()            ← non-blocking, lỗi không crash app
```

**Khi thêm service mới vào startup:**
- Nếu cần trước DI → Phase 0/1
- Nếu dùng getIt<> → Phase 3 trở đi (sau `configureDependencies`)
- Nếu không block UI → dùng `Future.wait` hoặc tách như IapService

---

## AppStartup (`app/app_startup.dart`)

Chạy từ **SplashScreen** sau khi widget tree sẵn sàng (cần `BuildContext`).

```dart
final isFirstRun = await AppStartup.launch(context);
// true  → navigate to onboarding
// false → navigate to home / login
```

Thứ tự:
1. Kiểm tra network — nếu offline thì chờ bằng `Completer` + `NetworkMonitor`
2. `AppVersionService.checkForUpdate(context)` — non-blocking
3. `LocalStorageService.isFirstRun()` → trả về bool

---

## Env files (`env/`)

Hiện tại **commented-out** — config đang dùng `ApiConstants` hardcode.

Nếu cần kích hoạt `envied` (bảo mật hơn cho API keys):
1. Tạo file `.env.dev`, `.env.stg`, `.env.prod` ở root
2. Uncomment nội dung trong `env_dev.dart`, `env_stg.dart`, `env_prod.dart`
3. Thêm `@EnviedField(obfuscate: true)` cho sensitive keys
4. Chạy `make gen`

---

## Observers (`observers/`)

### AppBlocObserver
- Active **chỉ** khi `FlavorConfig.isDev || FlavorConfig.isStg`
- Log: `onEvent`, `onChange` (state transition), `onError`
- Đăng ký trong `AppInitializer._configureBlocObserver()`

### AppObserver (Singleton)
- Monitor app lifecycle qua `WidgetsBindingObserver`
- Cho phép đăng ký callback resume/pause từ bất cứ đâu:

```dart
AppObserver().addOnResumeCallback(() => cubit.refresh());
AppObserver().addOnPauseCallback(() => player.pause());
// Nhớ remove trong dispose
AppObserver().removeOnResumeCallback(callback);
```

---

## SystemUIManager (`ui/system_ui_manager.dart`)

Singleton, khởi tạo trong `AppInitializer` Phase 1.

- Lock orientation: **portrait only**
- Android: cấu hình status bar + navigation bar theo SDK version
- iOS: cấu hình status bar style

```dart
// Gọi thủ công nếu cần thay đổi sau runtime
SystemUIManager.instance.setFullscreen(true);
SystemUIManager.instance.resetSystemUI();
```

---

## Quy tắc khi làm việc với config

- `FlavorConfig.setFlavor()` chỉ gọi **1 lần** trong `main_*.dart` — không gọi ở nơi khác
- Service cần `getIt<>` → phải được thêm **sau** `configureDependencies()` trong AppInitializer
- Service không cần block UI → wrap trong `try/catch` riêng như `IapService`
- Thêm callback lifecycle → dùng `AppObserver`, không tự tạo `WidgetsBindingObserver` mới
- Env secrets → dùng `envied` với `obfuscate: true`, không hardcode trong source code
