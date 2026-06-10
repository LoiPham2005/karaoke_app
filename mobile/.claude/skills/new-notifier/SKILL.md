---
name: new-notifier
description: Viết một Riverpod Notifier mới từ đầu dùng BaseNotifier mixin. Dùng khi cần notifier cho use case cụ thể — list, detail, form, paginated. Trigger: "viết notifier", "tạo provider", "notifier cho màn hình..."
argument-hint: [FeatureName] [list|detail|form|paginated]
allowed-tools: Read Write Edit Glob Grep
---

# Viết Notifier: $ARGUMENTS

Mẫu gốc: `lib/features/example/voucher/presentation/providers/voucher_pure_notifier.dart`

---

## List (phổ biến nhất)

```dart
part 'name_notifier.g.dart';

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

  Future<void> search(String query) => runAsync(
    action: () => _service.search(query),
    cancelPrevious: true,
    keepPreviousOnLoading: true,
    emitEmptyForEmptyList: true,
  );

  Future<void> create(NameModel item) => runAsync(
    action: () async {
      final created = await _service.create(item);
      return [created, ...(currentData ?? [])];
    },
    successMessage: 'Tạo thành công',
  );

  Future<void> delete(String id) {
    final snapshot = currentData ?? [];
    state = AsyncData(snapshot.where((e) => e.id != id).toList()); // optimistic
    return runAsync(
      action: () async {
        await _service.delete(id);
        return currentData ?? [];
      },
      errorMessage: 'Xóa thất bại',
      onError: (_, __) => state = AsyncData(snapshot), // rollback
    );
  }

  Future<void> update(String id, NameModel item) => runAsync(
    action: () async {
      final updated = await _service.update(id, item);
      return (currentData ?? []).map((e) => e.id == id ? updated : e).toList();
    },
    successMessage: 'Cập nhật thành công',
  );
}
```

---

## Paginated

```dart
@riverpod
class NameNotifier extends _$NameNotifier with BaseNotifier<List<NameModel>> {
  late NameService _service;
  int _page = 1;
  String _query = '';

  @override
  Future<List<NameModel>> build() async {
    _service = NameService(ref.read(dioProvider));
    return _loadPage(1);
  }

  Future<List<NameModel>> _loadPage(int page) async {
    final res = await _service.getListPaginated(page: page, query: _query);
    if (!res.isSuccess || res.data == null) throw ServerException(message: res.message ?? '');
    _paginationMeta = res.data!.meta;
    return res.data!.data;
  }

  Future<void> refresh() {
    _page = 1;
    return runAsync(
      action: () => _loadPage(1),
      keepPreviousOnLoading: true,
      cancelPrevious: true,
    );
  }

  Future<void> loadMore() async {
    if (!hasMore) return;
    _page++;
    final next = await _service.getListPaginated(page: _page, query: _query);
    if (next.isSuccess && next.data != null) {
      _paginationMeta = next.data!.meta;
      state = AsyncData([...(currentData ?? []), ...next.data!.data]);
    }
  }

  Future<void> search(String query) {
    _query = query;
    _page = 1;
    return runAsync(
      action: () => _loadPage(1),
      cancelPrevious: true,
      keepPreviousOnLoading: true,
      emitEmptyForEmptyList: true,
    );
  }
}
```

---

## Detail (single item)

```dart
@riverpod
class NameDetailNotifier extends _$NameDetailNotifier with BaseNotifier<NameModel> {
  late NameService _service;

  @override
  Future<NameModel> build(String id) async {
    _service = NameService(ref.read(dioProvider));
    return _service.getDetail(id);
  }

  Future<void> refresh(String id) => runAsync(
    action: () => _service.getDetail(id),
    keepPreviousOnLoading: true,
  );
}
```

---

## Form / mutation only

```dart
@riverpod
class NameFormNotifier extends _$NameFormNotifier with BaseNotifier<NameModel?> {
  late NameService _service;

  @override
  Future<NameModel?> build() async {
    _service = NameService(ref.read(dioProvider));
    return null;
  }

  Future<void> submit(NameModel item) => runAsync(
    action: () => _service.create(item),
    successMessage: 'Gửi thành công',
  );
}
```

---

## runAsync flags — cheat sheet

| Flag | Khi nào dùng |
|---|---|
| `cancelPrevious: true` | Search, filter — bắt buộc |
| `keepPreviousOnLoading: true` | Refresh không flash trắng |
| `emitEmptyForEmptyList: true` | Phân biệt "đang load" vs "rỗng" |
| `successMessage: '...'` | Toast tự động khi thành công |
| `errorMessage: '...'` | Prefix toast khi lỗi |
| `onError: (e, s) => ...` | Rollback optimistic update |

---

## Chain nhiều bước async

```dart
Future<void> loadUnused() => runAsync(
  cancelPrevious: true,
  action: () async {
    final list = await _service.getList();            // bước 1
    final filtered = list.where((v) => !v.isUsed).toList(); // bước 2
    if (filtered.isEmpty) return filtered;
    final detail = await _service.getDetail(filtered.first.id); // bước 3
    return [detail, ...filtered.skip(1)];
  },
);
```

---

## Quy tắc bắt buộc

| Rule | Đúng | Sai |
|---|---|---|
| Annotation | `@riverpod` | `@injectable`, `@LazySingleton` |
| Extends | `_$NameNotifier` (codegen) | custom base class |
| Mixin | `with BaseNotifier<T>` | không có mixin |
| Service init | `ref.read(dioProvider)` trong `build()` | inject qua constructor |
| Search/filter | `cancelPrevious: true` | bỏ trống |
| Refresh | `keepPreviousOnLoading: true` | không có |
| Sau khi viết | Chạy **Build Runner** để gen `*.g.dart` | quên chạy |
