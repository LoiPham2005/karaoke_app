---
name: core-architecture
description: Toàn bộ kiến trúc lib/core/ — Extensions, Utils, Mixins, Constants, Network, Cache, Services, Base classes. Dùng khi làm việc với network, cache, storage, service, extension, utility bất kỳ nào trong core.
when_to_use: Trigger khi user hỏi về extension nào dùng được, cách gọi API, cache strategy, storage key, toast, navigation, permission, service có sẵn, use case pattern.
user-invocable: false
allowed-tools: Read Glob Grep
---

# Core Architecture — `lib/core/`

```
lib/core/
  common/
    constants/     — ApiConstants, AppConstants
    converters/    — JsonConverters (String→double/int)
    extensions/    — DateTime, Widget, Assets, L10n, String, Num, List
    mixins/        — FormMixin, ScrollMixin, LoadingMixin, ApiHandlerMixin
    utils/         — Logger, DeviceInfo, SafeCompleter, ErrorUtils, ImagePickerUtils
    widgets/       — AppErrorScreen
  data/
    cache/         — CacheService, CacheTtl, CacheStrategy
    network/
      interceptors/ — Auth, Logging, NetworkCheck, Retry, SmartCache
      api_client.dart, dio_client.dart, network_info.dart
      api_response.dart, api_paginated_data.dart
  services/        — Toast, Navigation, Notification, Permission, Crashlytics,
                     NetworkMonitor, AppVersion, File, Media
  base/
    usecases/      — UseCase, UseCaseNoParams, VoidUseCase, StreamUseCase, ...
    state/cubit/enum/ — BoolCubit
```

---

## Extensions

### DateTime (`datetime_extensions.dart`)

```dart
// Trên DateTime
date.format('dd/MM/yyyy')           // custom format
date.toDateString                   // 'dd/MM/yyyy'
date.toTimeString                   // 'HH:mm'
date.toDateTimeString               // 'dd/MM/yyyy HH:mm'
date.timeAgo                        // "5 phút trước" (tiếng Việt)
date.isToday / isYesterday / isTomorrow / isPast / isFuture
date.startOfDay / endOfDay / startOfMonth / endOfMonth
date.daysInMonth
date.addDays(7) / subtractDays(7)

// Trên DateTime?
date?.toDateStringOrEmpty           // "" nếu null
date?.timeAgoOrEmpty
```

### Widget (`widget_extensions.dart`)

```dart
// Padding / Margin
widget.paddingAll(16)
widget.paddingSymmetric(horizontal: 16, vertical: 8)
widget.paddingOnly(left: 8, top: 4)
widget.marginAll(8)

// Alignment
widget.center()
widget.align(Alignment.topLeft)
widget.alignTopCenter() / alignBottomRight() // ...etc

// Size
widget.withSize(width: 100, height: 50)
widget.withWidth(200)
widget.expanded(2) / flexible(1)

// Visibility
widget.opacity(0.5)
widget.visible(condition)
widget.showIf(isAdmin)

// Gesture
widget.onTap(() => ...)
widget.inkWell(onTap: ..., borderRadius: ...)

// Decoration
widget.card(elevation: 4)
widget.rounded(12)
widget.clipRRect(radius: 8)
widget.backgroundColor(Colors.white)

// Transform
widget.rotate(0.5)
widget.scale(1.2)

// Other
widget.safeArea()
widget.scrollable()
widget.hero('tag')
widget.ignorePointer(true)
widget.tooltip('hint')
```

### Assets (`assets_extensions.dart`)

```dart
// String path → Widget (auto-detect SVG vs Image)
'assets/icons/home.svg'.toWidget(width: 24, height: 24)
'assets/images/logo.png'.toImage(width: 120, fit: BoxFit.contain)
'assets/icons/star.svg'.toSvg(color: Colors.yellow)

// Lottie
'assets/animations/loading.json'.lottie(width: 200, repeat: true)

// Kiểm tra
'path.svg'.isSvg    // true
'path.png'.isImage  // true
```

### L10n (`l10n_extensions.dart`)

```dart
context.l10n.someKey    // AppLocalizations getter
```

---

## Utils

### Logger (`logger.dart`)

```dart
Logger.info('message', 'TAG')
Logger.warning('message')
Logger.error('message', error: e, stackTrace: st)
Logger.httpRequest('GET', url, data)
Logger.httpResponse('GET', url, 200, data, duration)
Logger.blocEvent('MyCubit', event)
Logger.blocState('MyCubit', prev, next)

// Sensitive fields tự động bị mask:
// password, token, access_token, refresh_token, authorization, secret, api_key, pin, otp, cvv
```

> `LoggerConfig.configure()` được gọi trong `AppInitializer` Phase 1 dựa trên `FlavorConfig`.

### DeviceInfo (`device_info.dart`)

```dart
DeviceInfo.isAndroid / isIOS / isMobile / isDesktop

await DeviceInfo.getAppVersion()    // "1.2.3"
await DeviceInfo.getBuildNumber()   // "42"
await DeviceInfo.getPackageName()   // "com.example.app"
await DeviceInfo.getDeviceId()      // unique device id
await DeviceInfo.isPhysicalDevice() // true/false
await DeviceInfo.getInfo()          // Map (cached)
```

### SafeCompleter (`safe_completer.dart`)

```dart
final c = SafeCompleter<String>();
if (!c.isCompleted) c.complete('value');
final result = await c.future;
```

> Dùng trong `AppStartup` để chờ kết nối mạng mà không double-complete.

### ImagePickerUtils (`image_picker_utils.dart`)

```dart
final file = await ImagePickerUtils.pickFromGallery(context);
final file = await ImagePickerUtils.pickFromCamera(context);
final files = await ImagePickerUtils.pickMultiple(context, maxCount: 5);
final compressed = await ImagePickerUtils.compressImage(file, 80);
final file = await ImagePickerUtils.showSourceDialog(context); // AlertDialog gallery/camera
```

---

## Mixins

### FormMixin

```dart
class MyPage extends StatefulWidget {...}
class _MyPageState extends State<MyPage> with FormMixin<MyPage> {
  void submit() {
    if (validateAndSave()) {
      final email = getFormField('email');
      // ...
    }
  }
  
  Widget build(BuildContext context) => Form(
    key: formKey,
    autovalidateMode: autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
    child: ...,
  );
}
```

### ScrollMixin (pagination)

```dart
class _MyState extends State<MyPage> with ScrollMixin<MyPage> {
  @override
  Future<void> onLoadMore() async {
    await cubit.loadMore();
  }
  
  Widget build(BuildContext context) => ListView(
    controller: scrollController,
    children: [...],
  );
  // Tự động gọi onLoadMore khi gần cuối
  // setHasMore(false) khi hết data
}
```

### LoadingMixin

```dart
class _MyState extends State<MyPage> with LoadingMixin<MyPage> {
  Future<void> doAction() => withLoading(() async {
    await someOperation();
  }, 'Đang xử lý...');
  
  // isLoading, loadingMessage available in build
  // withLoadingState('submit', action) for multiple loaders
}
```

### ApiHandlerMixin

```dart
class MyRepository with ApiHandlerMixin {
  Future<Result<User>> getUser(int id) =>
    safeCallUnwrap(() => _service.getUser(id));
    
  Future<Result<bool>> deleteUser(int id) =>
    safeCallBool(() => _service.deleteUser(id));
}
```

---

## Constants

### AppConstants (`app_constants.dart`)

```dart
AppConstants.defaultPageSize        // pagination page size
AppConstants.maxPageSize
AppConstants.androidPackageName
AppConstants.iosBundleId
AppConstants.appStoreId
AppConstants.revenueCatAppleKey     // IAP
AppConstants.revenueCatGoogleKey
AppConstants.premiumEntitlement
AppConstants.maxRetries             // 3
AppConstants.retryDelay             // Duration
```

### ApiConstants (`api_constants.dart`)

```dart
// Base URLs per flavor (dùng qua FlavorConfig.apiBaseUrl)
ApiConstants.baseUrlDev / baseUrlStg / baseUrlProd

// API keys per flavor (dùng qua FlavorConfig.googleMapsApiKey)
ApiConstants.googleMapsKeyDev / Stg / Prod
ApiConstants.stripeKeyDev / Stg / Prod
```

> **Không dùng trực tiếp** — luôn đọc qua `FlavorConfig.*`.

---

## Network Layer

### ApiResponse / ApiPaginatedData

```dart
// Service trả về:
Future<ApiResponse<UserModel>> getUser(int id);
Future<ApiResponse<ApiPaginatedData<ProductModel>>> getProducts();

// Cubit dùng:
runServiceUnwrap(
  action: () => _service.getUser(id),
  mapper: (user) => user,                    // ApiResponse<T> → T
)

runServiceUnwrapPagination(
  action: () => _service.getProducts(),
  mapper: (paginated) => paginated.data,     // ApiPaginatedData<T> → List<T>
)
```

### DioClient vs ApiClient

| | `DioClient` | `ApiClient` |
|---|---|---|
| Return | `Future<Response<T>>` | `Future<Result<T>>` |
| Error handling | Throws DioException | Wrapped trong Result |
| Cancel token | Manual | Tag-based auto |
| Cache | Qua interceptor | `.getWithCache()` helper |
| Batch | ❌ | `.batchGet()` |

> Service layer dùng `@RestApi` (retrofit) không dùng trực tiếp DioClient/ApiClient.

### Interceptor Order

```
Request:  SmartCache → Auth → Retry → NetworkCheck → Logging
Response: Logging → NetworkCheck → Retry → Auth → SmartCache
```

### SmartCacheInterceptor

```dart
// Gắn strategy vào request options
Options options = SmartCacheInterceptor.withStrategy(CacheStrategy.shortTerm);
Options options = SmartCacheInterceptor.forceRefresh();
```

### CacheStrategy

```dart
enum CacheStrategy {
  noCache,        // luôn fetch
  shortTerm,      // TTL 5 phút
  mediumTerm,     // TTL 1 giờ
  longTerm,       // TTL 1 ngày
  permanent,      // TTL 1 năm
  cacheFirst,     // dùng cache nếu có, fallback network
  networkFirst,   // fetch network trước, fallback cache khi lỗi
}
```

---

## Cache Layer

### CacheService (`cache_service.dart`)

```dart
// String
await CacheService.instance.setString('key', 'value', ttl: Duration(hours: 1));
await CacheService.instance.getString('key');

// JSON (auto encode/decode)
await CacheService.instance.setJson('key', myObject);
final data = await CacheService.instance.getJson<MyModel>('key');

// Cache-aside pattern
final result = await CacheService.instance.getOrFetch(
  'users_list',
  fetch: () => api.getUsers(),
  encode: (list) => jsonEncode(list.map((e) => e.toJson()).toList()),
  decode: (s) => (jsonDecode(s) as List).map((e) => UserModel.fromJson(e)).toList(),
  ttl: CacheTtl.medium,
);

// File cache
CacheService.instance.imageCache    // CacheManager for images
CacheService.instance.fileCache     // CacheManager for files

// Delete
await CacheService.instance.remove('key');
await CacheService.instance.removeByPrefix('user_');
await CacheService.instance.clear();
```

### CacheTtl

```dart
CacheTtl.short      // 5 phút
CacheTtl.medium     // 1 giờ
CacheTtl.long       // 1 ngày
CacheTtl.week       // 7 ngày
CacheTtl.permanent  // 365 ngày
```

---

## Services

### ToastService

```dart
// Global getter
toast.success('Lưu thành công');
toast.error('Có lỗi xảy ra', title: 'Lỗi');
toast.warning('Kết nối yếu');
toast.info('Cập nhật mới');
toast.loading('Đang tải...');
toast.showAdLoading();
toast.stopLoading();
toast.dismiss();
toast.fromException(e);   // auto format từ exception/Failure
```

### NavigationService

```dart
// Go Router (preferred)
getIt<NavigationService>().goTo('/profile');
getIt<NavigationService>().pushTo<Result>('/detail', extra: item);
getIt<NavigationService>().replaceTo('/home');
getIt<NavigationService>().popRoute();
getIt<NavigationService>().popToRoot();

// Traditional Navigator (dùng khi cần Widget)
getIt<NavigationService>().navPushAndRemoveAll(LoginPage());
```

> Trong widget dùng `context.go()` / `context.push()` của go_router trực tiếp. `NavigationService` dùng khi cần navigate từ service/cubit không có context.

### PermissionService

```dart
await getIt<PermissionService>().requestCamera(context);
await getIt<PermissionService>().requestPhotos(context);
await getIt<PermissionService>().requestNotification(context);
await getIt<PermissionService>().requestLocation(context);

// Kiểm tra
final granted = await getIt<PermissionService>().isGranted(Permission.camera);

// Mở Settings nếu denied permanently
await getIt<PermissionService>().openSettings();
```

### NotificationService

```dart
await getIt<NotificationService>().showNotification(
  1, 'Tiêu đề', 'Nội dung',
  payload: 'data',
);
await getIt<NotificationService>().scheduleNotification(
  2, 'Nhắc nhở', 'Nội dung',
  scheduledDate: DateTime.now().add(Duration(hours: 1)),
);
await getIt<NotificationService>().cancel(1);
```

### CrashlyticsService

```dart
await CrashlyticsService.instance.setUserId(userId);
await CrashlyticsService.instance.recordError(e, st, reason: 'context');
await CrashlyticsService.instance.log('custom event');
await CrashlyticsService.instance.setCustomKey('plan', 'premium');
```

### NetworkMonitor

```dart
await NetworkMonitor.instance.startMonitoring(
  onConnected: () => cubit.refresh(),
  onDisconnected: () => toast.warning('Mất kết nối'),
  showBanner: true,
);
```

### AppVersionService

```dart
// Gọi từ AppStartup (đã tích hợp)
await AppVersionService().checkForUpdate(context);

// Lấy thông tin app
final info = await AppVersionService().getAppInfo();
// info.version, info.buildNumber, info.appName
```

### FileService

```dart
final file = await FileService.instance.downloadFile(
  url,
  fileName: 'report.pdf',
  onProgress: (progress) => setState(() => _progress = progress),
);
await FileService.instance.openFile(file!);
await FileService.instance.downloadAndOpen(url);

FileService.instance.isPdf(path)    // true/false
FileService.instance.isImage(path)  // true/false
```

### MediaService

```dart
await MediaService.instance.saveImage(filePath, albumName: 'MyApp');
await MediaService.instance.saveVideo(filePath);
```

---

## Base — UseCases

```dart
// Khi cần business logic riêng (không phổ biến, hầu hết dùng Cubit trực tiếp)

class GetUserUseCase extends UseCase<UserModel, int> {
  @override
  FutureResult<UserModel> call(int userId) async {
    // ...
  }
}

class GetUsersUseCase extends UseCaseNoParams<List<UserModel>> { ... }
class DeleteUserUseCase extends VoidUseCase<int> { ... }
class SyncUseCase extends SyncUseCaseNoParams<String> { ... }
class WatchOrdersUseCase extends StreamUseCase<Order, String> { ... }
```

---

## Base — BoolCubit

```dart
// Dùng cho các state boolean đơn giản (isExpanded, isSelected, ...)
@injectable
class MyBoolCubit extends BoolCubit {
  MyBoolCubit() : super(false);
}

// Trong widget
cubit.toggle();
cubit.setValue(true);
BlocBuilder<MyBoolCubit, bool>(builder: (ctx, isActive) => ...)
```

---

## Converters

```dart
// Dùng trong @freezed model khi API trả về số dạng String

@JsonSerializable()
class PriceModel {
  @StringToDoubleConverter()
  final double price;

  @StringToDoubleNullableConverter()
  final double? discount;

  @StringToIntConverter()
  final int quantity;
}
```

---

## Quy tắc

- `toast.*` → dùng global getter, không inject
- `NavigationService` → chỉ inject vào service/cubit không có context; trong widget dùng `context.go()`
- `CacheService` → `getOrFetch` cho cache-aside, `setJson`/`getJson` cho data tĩnh
- `Logger.*` → không dùng `print()` trực tiếp
- Extensions → ưu tiên dùng thay vì viết `Padding(padding: EdgeInsets.all(16), child: ...)` thủ công
- Mixins → `FormMixin` cho form, `ScrollMixin` cho list có pagination, `LoadingMixin` cho state loading local trong widget
