import 'package:injectable/injectable.dart';

import '../../../../../core/base/errors/result.dart';
import '../../domain/entities/{{feature_name.snakeCase()}}.dart';
import '../../domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import '../datasources/{{feature_name.snakeCase()}}_remote_datasource.dart';

@LazySingleton(as: {{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}RepositoryImpl implements {{feature_name.pascalCase()}}Repository {
  final {{feature_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  {{feature_name.pascalCase()}}RepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<{{feature_name.pascalCase()}}>>> get{{feature_name.pascalCase()}}s({
    Map<String, dynamic>? params,
  }) async {
    final result = await _remoteDataSource.get{{feature_name.pascalCase()}}s(params: params);
    return result.mapItems((model) => model.toEntity());
  }

  @override
  Future<Result<{{feature_name.pascalCase()}}>> get{{feature_name.pascalCase()}}Detail(String id) async {
    final result = await _remoteDataSource.get{{feature_name.pascalCase()}}Detail(id);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Result<{{feature_name.pascalCase()}}>> create{{feature_name.pascalCase()}}(Map<String, dynamic> data) async {
    final result = await _remoteDataSource.create{{feature_name.pascalCase()}}(data);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Result<{{feature_name.pascalCase()}}>> update{{feature_name.pascalCase()}}(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await _remoteDataSource.update{{feature_name.pascalCase()}}(id, data);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id) async {
    return await _remoteDataSource.delete{{feature_name.pascalCase()}}(id);
  }
}
