import '../../../../../../core/base/state/cubit/base_cubit.dart';
import '../../../../../../lib/features/{{name.snakeCase()}}/presentation/models/{{name.snakeCase()}}_model.dart';
import '../../../../../../lib/features/{{name.snakeCase()}}/presentation/repositories/{{name.snakeCase()}}_repository.dart';

class {{name.pascalCase()}}Cubit extends BaseCubit<List<{{name.pascalCase()}}Model>> {
  final {{name.pascalCase()}}Repository _repository;

  {{name.pascalCase()}}Cubit(this._repository);

  Future<void> fetchList() async {
    await run<List<{{name.pascalCase()}}Model>>(
      action: () => _repository.getList(),
    );
  }
}
