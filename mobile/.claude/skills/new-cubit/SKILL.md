---
name: new-cubit
description: Viết một BaseCubit mới từ đầu. Dùng khi cần cubit cho use case cụ thể mà brick không cover — detail screen, form submit, complex chain. Trigger: "viết cubit", "tạo cubit", "cubit cho màn hình..."
argument-hint: [FeatureName] [list|detail|form]
allowed-tools: Read Write Edit Glob Grep
---

# Viết Cubit: $ARGUMENTS

Chọn template phù hợp với use case, điền tên class thay cho `Name`.

## List CRUD (phổ biến nhất)

```dart
@injectable
class NameListCubit extends BaseCubit<List<NameModel>> {
  final NameService _service;
  Map<String, dynamic>? _lastParams;

  NameListCubit(this._service) : super(const BaseState.initial());

  Future<void> loadList({Map<String, dynamic>? params}) {
    _lastParams = params;
    return runServiceUnwrap(
      action: () => _service.getList(params: params),
      mapper: (paginated) => paginated.data,
      cancelPrevious: true,
    );
  }

  Future<void> refresh() => runServiceUnwrap(
    action: () => _service.getList(params: _lastParams),
    mapper: (paginated) => paginated.data,
    loadingState: BaseState.loading(previousData: state.data),
    cancelPrevious: true,
  );

  Future<void> create(NameModel item) => runServiceUnwrap<NameModel>(
    action: () => _service.create(item.toJson()),
    mapper: (created) => [created, ...(state.data ?? [])],
    successMessage: 'Tạo thành công',
  );

  Future<void> delete(int id) => runService<void>(
    action: () => _service.delete(id),
    mapper: (_) => (state.data ?? []).where((e) => e.id != id).toList(),
    successMessage: 'Xóa thành công',
  );
}
```

## Detail (single item)

```dart
@injectable
class NameDetailCubit extends BaseCubit<NameModel> {
  final NameService _service;
  NameDetailCubit(this._service) : super(const BaseState.initial());

  Future<void> load(int id) => runServiceUnwrap(
    action: () => _service.getDetail(id),
  );
}
```

## Form (submit only)

```dart
@injectable
class NameFormCubit extends BaseCubit<NameModel?> {
  final NameService _service;
  NameFormCubit(this._service) : super(const BaseState.initial());

  Future<void> submit(NameModel item) => runServiceUnwrap<NameModel>(
    action: () => _service.create(item.toJson()),
    successMessage: 'Gửi thành công',
  );
}
```

## Quy tắc bắt buộc

| Rule | Đúng | Sai |
|---|---|---|
| Init state | `const BaseState.initial()` | `BaseState.initial()` |
| DI annotation | `@injectable` | `@LazySingleton()` |
| Load/refresh | `cancelPrevious: true` | Bỏ trống |
| Refresh loading | `loadingState: BaseState.loading(previousData: state.data)` | Không có |
| Service method | `runServiceUnwrap` | `runResultUnwrap` |
