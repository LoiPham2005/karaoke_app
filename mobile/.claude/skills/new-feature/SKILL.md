---
name: new-feature
description: Scaffold một feature Flutter hoàn chỉnh theo chuẩn project (Riverpod + codegen). Dùng khi user nói "tạo feature", "tạo màn hình", "thêm module" hoặc hỏi cách bắt đầu một feature mới.
argument-hint: [feature-name]
disable-model-invocation: false
allowed-tools: Bash Read Write Edit Glob Grep
---

# Tạo Feature Mới: $ARGUMENTS

Mẫu chuẩn: `lib/features/example/voucher/` — đọc trước khi bắt đầu.

---

## Bước 1 — Tạo cấu trúc thư mục

```
lib/features/$ARGUMENTS/
  data/
    models/{name}_model.dart
    services/{name}_service.dart
  presentation/
    providers/{name}_notifier.dart
    pages/{name}_page.dart
```

---

## Bước 2 — Model (`@freezed`)

```dart
// data/models/{name}_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_model.freezed.dart';
part '{name}_model.g.dart';

@freezed
abstract class NameModel with _$NameModel {
  const factory NameModel({
    required String id,
    required String title,
    // thêm fields theo API contract
    @Default(false) bool isActive,
  }) = _NameModel;

  factory NameModel.fromJson(Map<String, dynamic> json) => _$NameModelFromJson(json);
}
```

`field_rename: snake` đã bật → `some_field` tự map sang `someField`, không cần `@JsonKey` trừ khi tên thực sự khác.

---

## Bước 3 — Service (`@RestApi` Retrofit)

```dart
// data/services/{name}_service.dart
import 'package:flutter_base/core/data/network/api_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part '{name}_service.g.dart';

@RestApi()
abstract class NameService {
  factory NameService(Dio dio, {String? baseUrl}) = _NameService;

  @GET('/names')
  Future<List<NameModel>> getList();

  @GET('/names/{id}')
  Future<NameModel> getDetail(@Path('id') String id);

  @POST('/names')
  Future<NameModel> create(@Body() NameModel body);

  @PUT('/names/{id}')
  Future<NameModel> update(@Path('id') String id, @Body() NameModel body);

  @DELETE('/names/{id}')
  Future<void> delete(@Path('id') String id);
}
```

Service return type: `Future<T>` (raw) — interceptor tự xử lý exception → Failure.
Không bao giờ wrap `Result<>` ở service layer.

---

## Bước 4 — Notifier (`@riverpod` + `BaseNotifier`)

```dart
// presentation/providers/{name}_notifier.dart
import 'package:flutter_base/core/base/di/dio_provider.dart';
import 'package:flutter_base/core/base/state/riverpod/base_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{name}_notifier.g.dart';

@riverpod
class NameNotifier extends _$NameNotifier with BaseNotifier<List<NameModel>> {
  late NameService _service;

  @override
  Future<List<NameModel>> build() async {
    _service = NameService(ref.read(dioProvider));
    return _service.getList();
  }

  Future<void> refresh() => runAsync(
    action: _service.getList,
    keepPreviousOnLoading: true,
    cancelPrevious: true,
  );
}
```

Xem [notifier-patterns.md](notifier-patterns.md) để thêm search, create, delete, optimistic update.

---

## Bước 5 — Page (`HookConsumerWidget`)

```dart
// presentation/pages/{name}_page.dart
class NamePage extends HookConsumerWidget {
  const NamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nameProvider);
    final notifier = ref.read(nameProvider.notifier);

    // Tự động toast error/success
    useAsyncValueListener(provider: nameProvider, ref: ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Name')),
      body: switch (state) {
        AsyncValue(:final value?, isLoading: true) => Stack(  // refresh overlay
          children: [_buildList(value), const LinearProgressIndicator()],
        ),
        AsyncData(value: final list) when list.isEmpty =>     // empty
          const Center(child: Text('Không có dữ liệu')),
        AsyncData(:final value) => _buildList(value),         // success
        AsyncError(:final error) => Center(                   // error
          child: Column(children: [
            Text('$error'),
            ElevatedButton(onPressed: notifier.refresh, child: const Text('Thử lại')),
          ]),
        ),
        _ => const Center(child: CircularProgressIndicator()), // initial load
      },
    );
  }
}
```

---

## Bước 6 — Route

Dùng skill `/new-route` hoặc xem [route-guide.md](route-guide.md).

---

## Bước 7 — Build Runner

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Sinh ra: `*.freezed.dart`, `*.g.dart` (model + service + notifier + route).

---

## Checklist

- [ ] Model: `@freezed`, có `part *.freezed.dart` + `part *.g.dart`, có `fromJson`
- [ ] Service: return `Future<T>` không bọc `Result<>`, có `@RestApi()`
- [ ] Notifier: `@riverpod`, `with BaseNotifier<T>`, `cancelPrevious: true` trên search/refresh
- [ ] Page: `HookConsumerWidget`, switch 5 case, `useAsyncValueListener`
- [ ] Route: `@TypedGoRoute`, thêm vào `_publicRoutes` nếu public
- [ ] Build Runner chạy không lỗi
