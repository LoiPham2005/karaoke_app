# Notifier Patterns — Supporting Reference

Mẫu gốc: `lib/features/example/voucher/presentation/providers/voucher_pure_notifier.dart`

## Template chuẩn (List CRUD)

```dart
@riverpod
class NameNotifier extends _$NameNotifier with BaseNotifier<List<NameModel>> {
  late NameService _service;
  String _lastQuery = '';

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

  Future<void> search(String query) {
    _lastQuery = query;
    return runAsync(
      action: () => _service.search(query),
      cancelPrevious: true,
      keepPreviousOnLoading: true,
      emitEmptyForEmptyList: true,
    );
  }

  Future<void> create(NameModel item) => runAsync(
    action: () async {
      final created = await _service.create(item);
      return [created, ...(currentData ?? [])];
    },
    successMessage: 'Tạo thành công',
  );

  Future<void> update(String id, NameModel item) => runAsync(
    action: () async {
      final updated = await _service.update(id, item);
      return (currentData ?? []).map((e) => e.id == id ? updated : e).toList();
    },
    successMessage: 'Cập nhật thành công',
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

  Future<void> toggleActive(String id) => runAsync(
    action: () async {
      final item = currentData?.firstWhere((e) => e.id == id);
      if (item == null) return currentData ?? [];
      final updated = await _service.update(id, item.copyWith(isActive: !item.isActive));
      return (currentData ?? []).map((e) => e.id == id ? updated : e).toList();
    },
  );
}
```

## Pagination (load more)

```dart
@riverpod
class NameNotifier extends _$NameNotifier with BaseNotifier<List<NameModel>> {
  late NameService _service;
  int _page = 1;

  @override
  Future<List<NameModel>> build() async {
    _service = NameService(ref.read(dioProvider));
    return _loadPage(1);
  }

  Future<List<NameModel>> _loadPage(int page) =>
    runPagination(
      action: () => _service.getListPaginated(page: page),
      mapper: (items) => page == 1 ? items : [...(currentData ?? []), ...items],
    ).then((_) => currentData ?? []);

  Future<void> refresh() {
    _page = 1;
    return runPagination(
      action: () => _service.getListPaginated(page: 1),
      mapper: (items) => items,
      keepPreviousOnLoading: true,
      cancelPrevious: true,
    );
  }

  Future<void> loadMore() async {
    if (!hasMore) return;
    _page++;
    await runPagination(
      action: () => _service.getListPaginated(page: _page),
      mapper: (items) => [...(currentData ?? []), ...items],
    );
  }
}
```

## Chain nhiều bước async

```dart
// cancelPrevious bảo vệ toàn bộ chain — không cần check token từng bước
Future<void> loadAndEnrich() => runAsync(
  cancelPrevious: true,
  action: () async {
    final list = await _service.getList();              // bước 1: load
    final filtered = list.where((e) => e.isActive).toList(); // bước 2: filter
    if (filtered.isEmpty) return filtered;
    final detail = await _service.getDetail(filtered.first.id); // bước 3: enrich
    return [detail, ...filtered.skip(1)];
  },
);
```

## runUnwrap — khi service trả ApiResponse

```dart
// Dùng khi service return Future<ApiResponse<T>> thay vì raw Future<T>
Future<void> load() => runUnwrap(
  action: () => _service.getList(),   // Future<ApiResponse<List<NameModel>>>
  mapper: (data) => data,
  cancelPrevious: true,
  keepPreviousOnLoading: true,
);
```

## runResult — khi có Repository layer

```dart
// Dùng khi repository trả Future<Result<T>>
Future<void> load() => runResult(
  action: () => _repository.getList(),
  mapper: (data) => data,
);
```

## Failure-aware actions

```dart
// lastFailure có type → UI pattern-match để xử lý khác nhau
Future<void> submit(String code) => runAsync(
  action: () => _service.apply(code),
  onError: (e, _) {
    if (e is AuthFailure) {
      // navigate to login
    }
  },
);

// Page đọc sau khi error:
// if (notifier.lastFailure is AuthFailure) context.go(RouteNames.login);
```
