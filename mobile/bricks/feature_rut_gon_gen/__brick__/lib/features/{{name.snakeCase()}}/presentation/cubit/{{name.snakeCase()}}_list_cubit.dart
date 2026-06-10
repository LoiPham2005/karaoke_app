import 'package:injectable/injectable.dart';

import '../../../../../core/base/state/bloc/base_state.dart';
import '../../../../../core/base/state/cubit/base_cubit.dart';
import '../../data/models/{{name.snakeCase()}}_model.dart';
import '../../data/services/{{name.snakeCase()}}_service.dart';

@injectable
class {{name.pascalCase()}}ListCubit extends BaseCubit<List<{{name.pascalCase()}}Model>> {
  final {{name.pascalCase()}}Service _service;

  Map<String, dynamic>? _lastParams;

  {{name.pascalCase()}}ListCubit(this._service) : super(const BaseState.initial());

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

  Future<void> create({{name.pascalCase()}}Model item) =>
      runServiceUnwrap<{{name.pascalCase()}}Model>(
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
