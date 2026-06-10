import 'package:flutter_base/core/common/mixins/api_handler_mixin.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/errors/result.dart';
import '../models/{{feature_name.snakeCase()}}_model.dart';
import '{{feature_name.snakeCase()}}_service.dart';

abstract class {{feature_name.pascalCase()}}RemoteDataSource {
  Future<Result<List<{{feature_name.pascalCase()}}Model>>> get{{feature_name.pascalCase()}}s({Map<String, dynamic>? params});
  Future<Result<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}Detail(String id);
  Future<Result<{{feature_name.pascalCase()}}Model>> create{{feature_name.pascalCase()}}(Map<String, dynamic> data);
  Future<Result<{{feature_name.pascalCase()}}Model>> update{{feature_name.pascalCase()}}(String id, Map<String, dynamic> data);
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id);
}

@LazySingleton(as: {{feature_name.pascalCase()}}RemoteDataSource)
class {{feature_name.pascalCase()}}RemoteDataSourceImpl with ApiHandlerMixin implements {{feature_name.pascalCase()}}RemoteDataSource {
  {{feature_name.pascalCase()}}RemoteDataSourceImpl(this._service);
  final {{feature_name.pascalCase()}}Service _service;

  @override
  Future<Result<List<{{feature_name.pascalCase()}}Model>>> get{{feature_name.pascalCase()}}s({Map<String, dynamic>? params}) =>
      safeCall(() => _service.get{{feature_name.pascalCase()}}s(params: params));

  @override
  Future<Result<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}Detail(String id) =>
      safeCall(() => _service.get{{feature_name.pascalCase()}}Detail(id));

  @override
  Future<Result<{{feature_name.pascalCase()}}Model>> create{{feature_name.pascalCase()}}(Map<String, dynamic> data) =>
      safeCall(() => _service.create{{feature_name.pascalCase()}}(data));

  @override
  Future<Result<{{feature_name.pascalCase()}}Model>> update{{feature_name.pascalCase()}}(String id, Map<String, dynamic> data) =>
      safeCall(() => _service.update{{feature_name.pascalCase()}}(id, data));

  @override
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id) => safeCallBool(() => _service.delete{{feature_name.pascalCase()}}(id));
}
