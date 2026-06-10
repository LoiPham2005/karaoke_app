import 'package:injectable/injectable.dart';
import 'package:flutter_base/core/errors/result.dart';
import '../entities/{{feature_name.snakeCase()}}.dart';
import '../repositories/{{feature_name.snakeCase()}}_repository.dart';

{{#has_list}}
/// Get {{feature_name.lowerCase()}}s use case
@injectable
class Get{{feature_name.pascalCase()}}sUseCase {
  final {{feature_name.pascalCase()}}Repository _repository;

  Get{{feature_name.pascalCase()}}sUseCase(this._repository);

  Future<Result<List<{{feature_name.pascalCase()}}>>> call({
    Map<String, dynamic>? params,
  }) {
    return _repository.get{{feature_name.pascalCase()}}s(params: params);
  }
}
{{/has_list}}

{{#has_detail}}
/// Get {{feature_name.lowerCase()}} detail use case
@injectable
class Get{{feature_name.pascalCase()}}DetailUseCase {
  final {{feature_name.pascalCase()}}Repository _repository;

  Get{{feature_name.pascalCase()}}DetailUseCase(this._repository);

  Future<Result<{{feature_name.pascalCase()}}>> call(String id) {
    return _repository.get{{feature_name.pascalCase()}}Detail(id);
  }
}
{{/has_detail}}

{{#has_create}}
/// Create {{feature_name.lowerCase()}} use case
@injectable
class Create{{feature_name.pascalCase()}}UseCase {
  final {{feature_name.pascalCase()}}Repository _repository;

  Create{{feature_name.pascalCase()}}UseCase(this._repository);

  Future<Result<{{feature_name.pascalCase()}}>> call(Map<String, dynamic> data) {
    return _repository.create{{feature_name.pascalCase()}}(data);
  }
}
{{/has_create}}

{{#has_update}}
/// Update {{feature_name.lowerCase()}} use case
@injectable
class Update{{feature_name.pascalCase()}}UseCase {
  final {{feature_name.pascalCase()}}Repository _repository;

  Update{{feature_name.pascalCase()}}UseCase(this._repository);

  Future<Result<{{feature_name.pascalCase()}}>> call(
    String id,
    Map<String, dynamic> data,
  ) {
    return _repository.update{{feature_name.pascalCase()}}(id, data);
  }
}
{{/has_update}}

{{#has_delete}}
/// Delete {{feature_name.lowerCase()}} use case
@injectable
class Delete{{feature_name.pascalCase()}}UseCase {
  final {{feature_name.pascalCase()}}Repository _repository;

  Delete{{feature_name.pascalCase()}}UseCase(this._repository);

  Future<Result<bool>> call(String id) {
    return _repository.delete{{feature_name.pascalCase()}}(id);
  }
}
{{/has_delete}}
