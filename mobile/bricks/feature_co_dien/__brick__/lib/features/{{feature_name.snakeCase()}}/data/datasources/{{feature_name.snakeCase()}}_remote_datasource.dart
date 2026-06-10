import 'package:flutter_base/core/errors/result.dart';
import 'package:flutter_base/core/network/api_client.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/common/constants/api_endpoints.dart';
import '../models/{{feature_name.snakeCase()}}_model.dart';

abstract class {{feature_name.pascalCase()}}RemoteDataSource {
  {{#has_list}}
  Future<Result<List<{{feature_name.pascalCase()}}Model>>> get{{feature_name.pascalCase()}}s({
    Map<String, dynamic>? params,
  });
  {{/has_list}}
  {{#has_detail}}
  Future<Result<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}Detail(String id);
  {{/has_detail}}
  {{#has_create}}
  Future<Result<{{feature_name.pascalCase()}}Model>> create{{feature_name.pascalCase()}}(Map<String, dynamic> data);
  {{/has_create}}
  {{#has_update}}
  Future<Result<{{feature_name.pascalCase()}}Model>> update{{feature_name.pascalCase()}}(
    String id,
    Map<String, dynamic> data,
  );
  {{/has_update}}
  {{#has_delete}}
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id);
  {{/has_delete}}
}

@LazySingleton(as: {{feature_name.pascalCase()}}RemoteDataSource)
class {{feature_name.pascalCase()}}RemoteDataSourceImpl implements {{feature_name.pascalCase()}}RemoteDataSource {
  {{feature_name.pascalCase()}}RemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  {{#has_list}}
  @override
  Future<Result<List<{{feature_name.pascalCase()}}Model>>> get{{feature_name.pascalCase()}}s({
    Map<String, dynamic>? params,
  }) async {
    return _apiClient.get(
      ApiEndpoints.apiEndpoints,
      (json) => json.map((e) => {{feature_name.pascalCase()}}Model.fromJson(e)).toList(),
      queryParameters: params,
    );
  }
  {{/has_list}}

  {{#has_detail}}
  @override
  Future<Result<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}Detail(String id) {
    return _apiClient.get(
      '${ApiEndpoints.apiEndpoints}/$id',
      (json) => {{feature_name.pascalCase()}}Model.fromJson(json),
    );
  }
  {{/has_detail}}

  {{#has_create}}
  @override
  Future<Result<{{feature_name.pascalCase()}}Model>> create{{feature_name.pascalCase()}}(Map<String, dynamic> data) {
    return _apiClient.post(
      ApiEndpoints.apiEndpoints,
      (json) => {{feature_name.pascalCase()}}Model.fromJson(json),
      data: data,
    );
  }
  {{/has_create}}

  {{#has_update}}
  @override
  Future<Result<{{feature_name.pascalCase()}}Model>> update{{feature_name.pascalCase()}}(
    String id,
    Map<String, dynamic> data,
  ) {
    return _apiClient.put(
      '${ApiEndpoints.apiEndpoints}/$id',
      (json) => {{feature_name.pascalCase()}}Model.fromJson(json),
      data: data,
    );
  }
  {{/has_update}}

  {{#has_delete}}
  @override
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id) {
    return _apiClient.delete('${ApiEndpoints.apiEndpoints}/$id');
  }
  {{/has_delete}}
}
