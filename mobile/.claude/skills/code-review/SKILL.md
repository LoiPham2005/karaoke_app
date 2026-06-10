---
name: code-review
description: Review code Flutter theo chuẩn project — kiểm tra Service, Model, Notifier, Page, Route. Dùng khi user nói "review code", "check code", "kiểm tra file này có đúng không".
argument-hint: [file-path hoặc feature-name]
disable-model-invocation: false
allowed-tools: Read Glob Grep
---

# Code Review: $ARGUMENTS

Đọc file được chỉ định rồi kiểm tra từng mục theo checklist. Báo cáo: ✅ đúng / ❌ sai (kèm dòng code) / ⚠️ cần chú ý.

## Service layer
- [ ] Return type `Future<T>` (raw) hoặc `Future<ApiResponse<T>>` — **không** bao giờ `Future<Result<...>>`
- [ ] `Future<void>` cho DELETE / side-effect không có return
- [ ] `@RestApi()` và `factory NameService(Dio dio)` đúng chuẩn Retrofit
- [ ] Endpoint không hardcode string — dùng constant hoặc path rõ ràng
- [ ] `@Queries()` cho filter, `@Path()` cho path param, `@Body()` cho body

## Model layer
- [ ] `@freezed abstract class` + `with _$ClassName`
- [ ] Có `part '*.freezed.dart'` + `part '*.g.dart'`
- [ ] `factory fromJson` có
- [ ] Field nullable đúng với API contract
- [ ] Không dùng `@JsonKey` không cần thiết (`field_rename: snake` đã bật)

## Notifier layer (Riverpod — PRIMARY)
- [ ] `@riverpod` annotation
- [ ] `extends _$NameNotifier` (codegen class)
- [ ] `with BaseNotifier<T>` mixin
- [ ] `build()` khởi tạo service qua `ref.read(dioProvider)`
- [ ] Search/filter: `cancelPrevious: true` — bắt buộc
- [ ] Refresh: `keepPreviousOnLoading: true` — không flash trắng
- [ ] Create/update/delete: `successMessage` có
- [ ] Optimistic delete: `onError: (_, __) => state = AsyncData(snapshot)` để rollback
- [ ] Không có `_generation`, `_previousData` thủ công (BaseNotifier đã handle)

## Page / UI layer
- [ ] `HookConsumerWidget` (không dùng `StatefulWidget` cho async state)
- [ ] `useAsyncValueListener(provider: xyzProvider, ref: ref)` — toast tự động
- [ ] `switch (state)` xử lý đủ 5 case:
  - `AsyncValue(:final value?, isLoading: true)` → refresh overlay
  - `AsyncData(value: final list) when list.isEmpty` → empty state
  - `AsyncData(:final value)` → success
  - `AsyncError(:final error)` → error + retry
  - `_` → initial loading spinner
- [ ] Không gọi notifier method trong `build()` — chỉ trong `onPressed`, `onChanged`
- [ ] `ref.read(xyzProvider.notifier)` để gọi method (không `ref.watch`)

## Route
- [ ] `@TypedGoRoute<XxxRoute>(path: RouteNames.xxx)`
- [ ] `with $XxxRoute` mixin
- [ ] Path constant trong `lib/routes/config/route_names.dart`
- [ ] Route public thêm vào `_publicRoutes` trong `route_guards.dart`
- [ ] Build Runner chạy — có `$XxxRoute` mixin trong `app_routes.g.dart`

## DI & codegen
- [ ] Notifier: không cần annotation — Riverpod tự quản lý
- [ ] Service: `@LazySingleton()` nếu dùng get_it (hoặc khởi tạo thủ công qua `ref.read(dioProvider)`)
- [ ] Sau khi thêm `@riverpod`, `@freezed`, `@RestApi` → Build Runner đã chạy

## Failure handling
- [ ] Không expose raw `e.toString()` ra UI — dùng `error is Failure ? error.userMessage : ...`
- [ ] `notifier.lastFailure` để pattern-match failure type trên UI nếu cần
- [ ] `onError` callback cho rollback, không dùng try/catch bọc toàn bộ method
