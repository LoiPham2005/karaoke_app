import 'package:flutter_base/core/base/errors/result.dart';
import 'package:flutter_base/core/common/mixins/api_handler_mixin.dart';
import 'package:injectable/injectable.dart';

import '../models/{{feature_name.snakeCase()}}_model.dart';
import '../services/{{feature_name.snakeCase()}}_service.dart';

@LazySingleton()
class {{feature_name.pascalCase()}}Repository with ApiHandlerMixin {
  final {{feature_name.pascalCase()}}Service _service;

  {{feature_name.pascalCase()}}Repository(this._service);

  Future<Result<List<{{feature_name.pascalCase()}}Model>>> get{{feature_name.pascalCase()}}s({Map<String, dynamic>? params}) {
    return safeCall(() => _service.get{{feature_name.pascalCase()}}s(params: params));
  }

  Future<Result<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}Detail(String id) {
    return safeCall(() => _service.get{{feature_name.pascalCase()}}Detail(id));
  }

  Future<Result<{{feature_name.pascalCase()}}Model>> create{{feature_name.pascalCase()}}(import 'package:flutter_base/core/base/errors/result.dart';
import 'package:flutter_base/core/common/mixins/api_handler_mixin.dart';
import 'package:injectable/injectable.dart';

import '../models/{{feature_name.snakeCase()}}_model.dart';
import '../services/{{feature_name.snakeCase()}}_service.dart';

@LazySingleton()
class {{feature_name.pascalCase()}}Repository with ApiHandlerMixin {
  final {{feature_name.pascalCase()}}Service _service;

  {{feature_name.pascalCase()}}Repository(this._service);

  Future<Result<List<{{feature_name.pascalCase()}}Model>>> get{{feature_name.pascalCase()}}s({Map<String, dynamic>? params}) {
    return safeCall(() => _service.get{{feature_name.pascalCase()}}s(params: params));
  }

  Future<Result<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}Detail(String id) {
    return safeCall(() => _service.get{{feature_name.pascalCase()}}Detail(id));
  }

  Future<Result<{{feature_name.pascalCase()}}Model>> create{{feature_name.pascalCase()}}({{feature_name.pascalCase()}}Model data) {
    return safeCall(() => _service.create{{feature_name.pascalCase()}}(data));
  }

  Future<Result<{{feature_name.pascalCase()}}Model>> update{{feature_name.pascalCase()}}(String id, {{feature_name.pascalCase()}}Model data) {
    return safeCall(() => _service.update{{feature_name.pascalCase()}}(id, data));
  }

  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id) {
    return safeCallBool(() => _service.delete{{feature_name.pascalCase()}}(id));
  }
}
