# Cubit Patterns — Supporting Reference

## Template chuẩn (List CRUD)

```dart
@injectable
class NameListCubit extends BaseCubit<List<NameModel>> {
  final NameService _service;
  Map<String, dynamic>? _lastParams;
  int _currentPage = 1;

  NameListCubit(this._service) : super(const BaseState.initial());

  Future<void> loadList({Map<String, dynamic>? params}) {
    _lastParams = params;
    _currentPage = 1;
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

  Future<void> loadMore() {
    _currentPage++;
    return runServiceUnwrapPagination(
      action: () => _service.getList(params: {...?_lastParams, 'page': _currentPage}),
      mapper: (items) => [...(state.data ?? []), ...items],
    );
  }

  Future<void> create(NameModel item) => runServiceUnwrap<NameModel>(
    action: () => _service.create(item.toJson()),
    mapper: (created) => [created, ...(state.data ?? [])],
    successMessage: 'Tạo thành công',
  );

  Future<void> update(int id, NameModel item) => runServiceUnwrap<NameModel>(
    action: () => _service.update(id, item.toJson()),
    mapper: (updated) => (state.data ?? []).map((e) => e.id == id ? updated : e).toList(),
    successMessage: 'Cập nhật thành công',
  );

  Future<void> delete(int id) => runService<void>(
    action: () => _service.delete(id),
    mapper: (_) => (state.data ?? []).where((e) => e.id != id).toList(),
    successMessage: 'Xóa thành công',
  );

  Future<void> toggleActive(int id) {
    final item = state.data?.firstWhere((e) => e.id == id);
    if (item == null) return Future.value();
    return runServiceUnwrap<NameModel>(
      action: () => _service.update(id, item.copyWith(isActive: !item.isActive).toJson()),
      mapper: (updated) => (state.data ?? []).map((e) => e.id == id ? updated : e).toList(),
    );
  }
}
```

## failureMapper — phân loại lỗi

```dart
failureMapper: (f, prev) => switch (f) {
  NetworkFailure() || TimeoutFailure() =>
    BaseState.failure(error: 'Mất kết nối', previousData: prev),
  AuthFailure() => BaseState.failure(error: 'Hết phiên đăng nhập'),
  DataFailure(type: DataFailureType.notFound) =>
    BaseState.empty(message: 'Không tìm thấy'),
  _ => BaseState.failure(error: f.message, previousData: prev),
},
```

## runChain — multi-step

```dart
Future<void> loadAndEnrich() => runChain(
  chain: () => _service.getList()
      .asResult()
      .thenMap((p) => p.data.where((e) => e.isActive).toList())
      .thenAsyncFlatMap(_enrichFirstItem),
);
```
