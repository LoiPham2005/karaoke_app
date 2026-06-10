import 'package:injectable/injectable.dart';

import '../../../../../core/base/usecases/params.dart';
import '../../../../../core/base/usecases/usecase.dart';
import '../entities/{{feature_name.snakeCase()}}.dart';
import '../repositories/{{feature_name.snakeCase()}}_repository.dart';

@injectable
final class Get{{feature_name.pascalCase()}}sUseCase extends UseCase<List<{{feature_name.pascalCase()}}>, SearchParams?> {
  final {{feature_name.pascalCase()}}Repository _repository;
  const Get{{feature_name.pascalCase()}}sUseCase(this._repository);

  @override
  FutureResult<List<{{feature_name.pascalCase()}}>> run(SearchParams? params) {
    return _repository.get{{feature_name.pascalCase()}}s(params: params?.toJson());
  }
}

@injectable
final class Get{{feature_name.pascalCase()}}DetailUseCase extends UseCase<{{feature_name.pascalCase()}}, String> {
  final {{feature_name.pascalCase()}}Repository _repository;
  const Get{{feature_name.pascalCase()}}DetailUseCase(this._repository);

  @override
  FutureResult<{{feature_name.pascalCase()}}>> run(String id) {
    return _repository.get{{feature_name.pascalCase()}}Detail(id);
  }
}

@injectable
final class Create{{feature_name.pascalCase()}}UseCase extends UseCase<{{feature_name.pascalCase()}}, Map<String, dynamic>> {
  final {{feature_name.pascalCase()}}Repository _repository;
  const Create{{feature_name.pascalCase()}}UseCase(this._repository);

  @override
  FutureResult<{{feature_name.pascalCase()}}>> run(Map<String, dynamic> data) {
    return _repository.create{{feature_name.pascalCase()}}(data);
  }
}

@injectable
final class Update{{feature_name.pascalCase()}}UseCase extends UseCase<{{feature_name.pascalCase()}}, {{feature_name.pascalCase()}}UpdateParams> {
  final {{feature_name.pascalCase()}}Repository _repository;
  const Update{{feature_name.pascalCase()}}UseCase(this._repository);

  @override
  FutureResult<{{feature_name.pascalCase()}}>> run({{feature_name.pascalCase()}}UpdateParams params) {
    return _repository.update{{feature_name.pascalCase()}}(params.id, params.data);
  }
}

@injectable
final class Delete{{feature_name.pascalCase()}}UseCase extends UseCase<bool, String> {
  final {{feature_name.pascalCase()}}Repository _repository;
  const Delete{{feature_name.pascalCase()}}UseCase(this._repository);

  @override
  FutureBoolResult run(String id) {
    return _repository.delete{{feature_name.pascalCase()}}(id);
  }
}

/// Params for update operation
final class {{feature_name.pascalCase()}}UpdateParams extends Params {
  final String id;
  final Map<String, dynamic> data;

  const {{feature_name.pascalCase()}}UpdateParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];

  @override
  Map<String, dynamic> toJson() => data;
}
