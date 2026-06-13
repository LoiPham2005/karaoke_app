# 📚 Features Guide

> Hướng dẫn dùng các services, modules, extensions có sẵn trong `flutter_base2`.

---

## 📋 Mục lục

- [Services](#services)
  - [NotificationService](#notificationservice)
  - [PermissionService](#permissionservice)
  - [AppVersionService](#appversionservice)
  - [QuickActionsService](#quickactionsservice)
  - [ImagePickerUtils](#imagepickerutils)
- [Modules](#modules)
  - [AdManager (Ads)](#adsmodule)
  - [IapService (IAP)](#iapmodule)
  - [AnalyticsService](#analyticsservice)
  - [AppConfigService](#appconfigservice)
- [Extensions](#extensions)
- [Theme & Localization](#theme--localization)

---

## 🛠️ Services

### NotificationService

**Path**: `lib/core/services/notification/notification_service.dart`
**Plugin**: `flutter_local_notifications`
**Mục đích**: Local notification (KHÔNG bao gồm push từ server).

#### Setup
```dart
// AppInitializer hoặc Splash:
final noti = getIt<NotificationService>();
await noti.initialize();

// Đăng ký callback routing (caller tự quyết định route):
noti.onTap = (payload) {
  switch (payload) {
    case 'go_premium': getIt<AppRouter>().push(const PremiumRoute());
    case 'open_voucher': getIt<AppRouter>().push(const VoucherListRoute());
  }
};
```

#### Show notification
```dart
await noti.showNotification(
  id: 1,
  title: 'Khuyến mãi mới!',
  body: 'Voucher giảm 50%',
  payload: 'open_voucher',
);

// Cancel
await noti.cancel(1);
await noti.cancelAll();
```

> ⚠️ `scheduleNotification()` chưa implement — cần setup timezone trước (`tz.initializeTimeZones()`).

---

### PermissionService

**Path**: `lib/core/services/permission/permission_service.dart`
**Plugin**: `permission_handler`
**Mục đích**: Request camera/photos/location/notification permission, auto dialog "Mở cài đặt" khi user permanently deny.

#### Use
```dart
final perm = getIt<PermissionService>();

final ok = await perm.requestCamera(context);
if (ok) { /* mở camera */ }

await perm.requestPhotos(context);
await perm.requestLocation(context);
await perm.requestNotification(context);

// Hoặc generic
await perm.request(Permission.contacts, context);
```

> iOS: nhớ thêm `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`... vào `Info.plist`.

---

### AppVersionService

**Path**: `lib/core/services/app_version/app_version_service.dart`
**Plugin**: `package_info_plus` + `firebase_remote_config` + `url_launcher`
**Mục đích**: Force/optional update via Firebase Remote Config + dialog UI.

#### Firebase Remote Config keys
| Key | Type | Mô tả |
|---|---|---|
| `force_update_version` | string | App version < này → **bắt buộc** update |
| `latest_version` | string | App version < này → **optional** update |
| `update_message` | string | Message hiển thị trong dialog |
| `update_url_android` | string | Override Play Store URL |
| `update_url_ios` | string | Override App Store URL |

#### Use (gọi từ Splash hoặc Settings page)
```dart
final svc = getIt<AppVersionService>();

final result = await svc.checkForUpdate(
  context: context,
  labels: AppVersionLabels.vi,         // hoặc .en
  storeIds: const StoreIds(
    androidPackage: 'com.example.flutter_base2',
    iosAppId: '1234567890',
  ),
);

switch (result) {
  case UpdateCheckResult.forceUpdate: break;    // dialog đã hiện
  case UpdateCheckResult.upToDate:
    context.router.replaceAll([const MainRoute()]);
  default:
    context.router.replaceAll([const MainRoute()]);
}
```

---

### QuickActionsService

**Path**: `lib/core/services/quick_actions/quick_actions_service.dart`
**Plugin**: `quick_actions`
**Mục đích**: App shortcuts khi user long-press app icon trên home screen.

#### Native setup
- **Android**: Vector icons có sẵn ở `android/app/src/main/res/drawable/ic_shortcut_*.xml` (search/logout/login/scan).
- **iOS**: Imageset folders ở `ios/Runner/Assets.xcassets/ic_shortcut_*.imageset/` — **cần thêm PNG file** (xem `QUICK_ACTIONS_README.md`).

#### Use
```dart
final qa = getIt<QuickActionsService>();

// Đăng ký handler (gọi 1 lần sau khi router ready):
await qa.initialize(
  onAction: (type) {
    final router = getIt<AppRouter>();
    switch (type) {
      case 'search':  router.push(const SearchRoute());
      case 'scan':    router.push(const ScannerRoute());
      case 'logout':  ref.read(appAuthProvider.notifier).logout();
      case 'login':   router.push(const LoginRoute());
    }
  },
);

// Đổi list theo auth state:
final isAuth = ref.watch(appAuthProvider).isAuthenticated;
await qa.setActions(
  isAuth
      ? [
          const QuickActionItem(type: 'search', label: 'Tìm kiếm', icon: 'ic_shortcut_search'),
          const QuickActionItem(type: 'scan', label: 'Quét QR', icon: 'ic_shortcut_scan'),
          const QuickActionItem(type: 'logout', label: 'Đăng xuất', icon: 'ic_shortcut_logout'),
        ]
      : [
          const QuickActionItem(type: 'login', label: 'Đăng nhập', icon: 'ic_shortcut_login'),
        ],
);
```

---

### ImagePickerUtils

**Path**: `lib/core/common/utils/image_picker_utils.dart`
**Plugins**: `image_picker` + `flutter_image_compress`
**Mục đích**: Pick ảnh từ camera/gallery + compress + UI dialog.

#### Use
```dart
// Dialog chọn nguồn (gallery / camera)
final file = await ImagePickerUtils.showSourceDialog(context);

// Hoặc pick trực tiếp
final file = await ImagePickerUtils.pickFromGallery(context);
final file = await ImagePickerUtils.pickFromCamera(context);

// Pick nhiều
final files = await ImagePickerUtils.pickMultiple(context, maxCount: 5);

// Compress
final compressed = await ImagePickerUtils.compressImage(
  file,
  quality: 85,
  maxWidth: 1920,
);

// Placeholder color cho avatar
final color = ImagePickerUtils.getPlaceholderColor(user.name);
```

> iOS: cần `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` trong `Info.plist` (đã có sẵn template).

---

## 📦 Modules

### AdsModule (AdManager)

**Path**: `lib/modules/ads/`
**Plugin**: `google_mobile_ads`
**Setup**: Tự động qua `AppInitializer._initAds()` (4 bước: ConfigService → ConsentService → AdManager → LifecycleObserver).

#### Data model (`ad_config.dart`)

```dart
AdConfig                       // top-level: flags + frequency + ad units
  ├── flags: showAllAds, enableInter/AppOpen/Rewarded/Native/Banner, ...
  ├── AdRules rules            // frequency cap rules
  └── AdUnits adUnits          // ← tên match AdMob Console "Ad units" menu

AdUnits                        // Map<String, AdUnit> per type
  ├── inter, appOpen, rewarded, native, banner

AdUnit
  ├── id, id2, useId2, enable
```

Truy cập: `cfg.adUnits.inter['splash']` hoặc `cfg.adUnits.inter[InterstitialPlacement.splash.key]`.

#### Use
```dart
// Top-level getter (tương đương getIt<AdManager>())
final ads = adManager;

// Interstitial sau khi user xong việc
await ads.showInter(
  InterstitialPlacement.afterQuiz,
  onDismissed: () => print('Ad closed'),
);

// App Open RESUME — auto qua AdLifecycleObserver, KHÔNG cần gọi tay
// App Open COLD START — GỌI TỪ SPLASH PAGE:
WidgetsBinding.instance.addPostFrameCallback((_) {
  adManager.showAppOpenOnLaunch();  // idempotent, fire 1 lần/session
});

// Rewarded với callback nhận reward
await ads.showRewarded(
  RewardedPlacement.bonus,
  onEarnedReward: (reward) => print('+${reward.amount} ${reward.type}'),
);

// Native overlay full-screen (dùng ad đã preload — instant)
ads.showNativeFull(onClosed: () { /* tiếp flow */ });

// Native widget in-feed (3 size: small / medium / full)
const NativeAdWidget(placement: NativePlacement.home)                        // medium default
const NativeAdWidget(placement: NativePlacement.home, size: NativeAdSize.small)
const NativeAdWidget(placement: NativePlacement.home, size: NativeAdSize.full)

// Banner widget (adaptive, rotation race-safe)
const AdBannerWidget(placement: BannerPlacement.home)

// A/B test dynamic placement
ads.showInter(const RawPlacement('experimental_v2'));

// Reset session (sau IAP refund / re-login)
ads.resetSession();

// Consent flow
await getIt<AdConsentService>().showPrivacyOptionsForm();
ads.onConsentChanged();
```

#### Production-grade features

| Feature | Cách hoạt động |
|---|---|
| UMP Consent (GDPR/CCPA) | `ConsentInformation` API, chạy TRƯỚC MobileAds.init |
| ATT iOS | `app_tracking_transparency`, request sau 200ms |
| Retry exponential + jitter | `AdRetryPolicy` 2s→4s→8s, max 3 retry |
| Network auto re-preload | `NetworkInfo.onStatusChange` → online lại = preload |
| Frequency cap per-type | All `Inter` share cooldown; `maxInterPerSession` không per-placement |
| Cross-handler cooldown | Inter/Rewarded vừa show → block AppOpen 10s |
| Cold start AppOpen | `showAppOpenOnLaunch()` idempotent sentinel |
| Race protection | `_showing` Set + `_loading` Completer + `Expando` cho Rewarded |
| Test device prod guard | `_testDeviceIds` forced empty ở prod flavor (assert) |

#### Native config bắt buộc
- **Android**: `AndroidManifest.xml` có `<meta-data com.google.android.gms.ads.APPLICATION_ID>` (test ID).
- **iOS**: `Info.plist` có `GADApplicationIdentifier` (test ID) + 15 `SKAdNetworkItems` + `NSUserTrackingUsageDescription`.
- ⚠️ **Production**: thay test App ID bằng App ID thật từ [apps.admob.com](https://apps.admob.com).

#### Native ad factories (3 đã register)
- **Android** (`MainActivity.kt`): `nativeSmall` / `nativeMedium` / `nativeFull` với layout XML ở `res/layout/native_ad_*.xml`.
- **iOS** (`AppDelegate.swift`): `nativeSmall` / `nativeMedium` / `nativeFull` với XIB ở `Runner/NativeAd*View.xib`.
  - ⚠️ `NativeAdFullView.xib` chưa có — phải tạo qua Xcode Interface Builder trước khi test iOS.

#### Demo
`lib/features/ads_demo/presentation/pages/ads_demo_page.dart` — route `AdsDemoRoute()`. Show tất cả placement có ad unit configured, switch native size qua SegmentedButton, auto re-build khi Remote Config update.

---

### IapModule

**Path**: `lib/modules/iap/`
**Plugin**: `purchases_flutter` (RevenueCat)
**DI**: `IapService` (prod/stg) + `MockIapService` (dev) — swap tự động theo flavor.

#### Setup
```dart
// AppInitializer tự gọi:
await getIt<IapService>().initialize();
await getIt<IapService>().initialize(userId: 'user_123');  // khi login
```

#### Premium status
```dart
final iap = getIt<IapService>();

iap.isPremium;                              // bool snapshot
iap.premiumStream.listen((p) => ...);       // reactive
```

#### Purchase
```dart
final result = await iap.purchasePackage(package);

switch (result.errorType) {
  case null:                            return 'Mua thành công';
  case PurchaseErrorType.cancelled:     return null;
  case PurchaseErrorType.network:       return 'Kiểm tra kết nối';
  case PurchaseErrorType.storeUnavailable: return 'Store tạm sự cố';
  case PurchaseErrorType.notAllowed:    return 'Thiết bị không cho phép';
  default: return result.message;
}
```

#### Restore
```dart
final result = await iap.restorePurchases();
if (result.isSuccess) { /* re-grant premium */ }
```

#### Mock test (dev flavor)
```dart
final mock = getIt<IapService>() as MockIapService;
mock.setNextResult(AppPurchaseResult.cancelled());   // test cancel flow
await iap.purchasePackage(pkg);  // → cancelled

mock.setNextResult(AppPurchaseResult.error(
  'No internet',
  type: PurchaseErrorType.network,
));
```

#### Setup keys (prod)
- `AppConstants.revenueCatGoogleKey` — Lấy từ RevenueCat Console
- `AppConstants.revenueCatAppleKey`
- `AppConstants.premiumEntitlement` (default: `'premium'`)

---

### AnalyticsService

**Path**: `lib/modules/analytics/analytics_service.dart`
**Plugin**: `firebase_analytics`

#### Use
```dart
final analytics = getIt<AnalyticsService>();

await analytics.logEvent(
  name: 'tutorial_complete',
  parameters: {'step': 5},
);

await analytics.logButtonClick(buttonName: 'cta_buy_premium');

await analytics.logScreenView('home');

await analytics.setUserId('user_123');

// Helper cho ad revenue (Firebase Ad Revenue spec)
await analytics.logAdRevenuePaid(
  value: 0.50,
  currency: 'USD',
  adPlatform: 'AdMob',
  adSource: 'AdMob',
  adUnitName: 'inter_home',
  adFormat: 'inter',
);
```

---

### AppConfigService

**Path**: `lib/modules/app_config/`
**Mục đích**: Generic feature flags + maintenance + notice banner + legal URLs từ Firebase Remote Config.

#### Firebase Remote Config — 1 key `app_config` (JSON string)
```json
{
  "maintenance_mode": false,
  "maintenance_message": "Bảo trì 2h-4h sáng",
  "notice_enabled": true,
  "notice_title": "🎉 Khuyến mãi",
  "notice_body": "Giảm 50%",
  "notice_url": "https://example.com/promo",
  "policy_url": "https://example.com/privacy",
  "terms_url": "https://example.com/terms"
}
```

#### Use — generic
```dart
final cfg = getIt<AppConfigService>();

if (cfg.isMaintenance) return MaintenanceScreen(message: cfg.maintenanceMessage);
if (cfg.hasNotice) showNoticeBanner(cfg.noticeTitle, cfg.noticeUrl);

// Settings page
ListTile(title: const Text('Privacy'), onTap: () => launchUrl(cfg.policyUrl));

// Custom flag (không cần thêm field vào model)
final showNewUi = cfg.getBool('show_new_checkout_ui');
```

#### Use — reactive với Riverpod
```dart
final cfg = ref.watch(appConfigSnapshotProvider).valueOrNull
    ?? AppConfigSnapshot.empty;

if (cfg.isMaintenance) return MaintenanceScreen(...);
```

#### Toggle local-only mode
File: `lib/modules/app_config/utils/app_config_defaults.dart`
```dart
const bool kUseAppRemoteConfig = true;  // false → dùng kAppConfigDev hardcoded
```

---

## 🧩 Extensions

### `core/common/extensions/`

| Extension | Use |
|---|---|
| `context_extensions` | `context.theme`, `context.screenWidth`, `appContext` global, `navPush()` |
| `datetime_extensions` | `dt.timeAgo`, `dt.dateOnly` |
| `string_extensions` | `'abc'.capitalize`, `.titleCase`, `.isEmail`, `.isValidPhoneVN`, `.removeDiacritics()`, `.maskPhone()`, `.maskEmail()`, `.toIntOrDefault()` |
| `number_extensions` | `5.seconds`, `1234567.toCurrency()`, `0.75.toPercentage()`, `.roundTo(2)` |
| `list_extensions` | `users.distinctBy((u) => u.id)`, `.groupBy`, `.sum`, `.maxBy`, `.chunk(10)` |
| `assets_extensions` | `'assets/logo.svg'.toSvg(width: 24)`, `.toImage()`, `.lottie()` |
| `widget_extensions` | `Text('hi').paddingAll(16).center().onTap(...)` (chain syntax) |
| `l10n_extensions` | `Text(context.l10n.welcome)` (shortcut cho AppLocalizations) |

### `core/common/utils/`

| Util | Use |
|---|---|
| `Validators` | `Validators.email`, `.phoneVN`, `.strongPassword`, `.otp`, `.loginForm` |
| `DeviceInfo` | `DeviceInfo.getDeviceId()`, `.getModel()`, `.isIOS` |
| `SafeCompleter<T>` | Tránh "Future already completed" bug |
| `ImagePickerUtils` | Xem [ImagePickerUtils](#imagepickerutils) |

---

## 🎨 Theme & Localization

### Theme — 4 variant (light / dark / red / green)

```dart
// Đổi theme runtime:
ref.read(themeProvider.notifier).set(AppThemeVariant.green);
```

Thêm theme mới:
1. `app_color_tokens.dart` — thêm `factory AppColorTokens.purple()`
2. `theme_notifier.dart` — thêm `purple('Tím')` vào `AppThemeVariant` enum
3. `app_theme.dart` — thêm case vào `fromVariant()`
4. `make gen`

### Localization (vi + en)

```dart
// File: lib/design/l10n/translations/app_vi.arb + app_en.arb
Text(context.l10n.welcome)   // dùng l10n_extensions

// Sync khoá còn thiếu giữa vi/en:
make l10n-sync
make l10n-sync-translate     // Google auto-translate những key trống
```

---

## 📖 Tham khảo

- **Patterns**: xem [`CLAUDE.md`](../CLAUDE.md) — Riverpod patterns, runAsync flags, service return types
- **Architecture**: xem [`docs/ARCHITECTURE.md`](./ARCHITECTURE.md) — layered + DI + folder structure
- **Setup checklist**: xem [`docs/CHECKLIST.md`](./CHECKLIST.md)
- **Contributing**: xem [`docs/CONTRIBUTING.md`](./CONTRIBUTING.md)
