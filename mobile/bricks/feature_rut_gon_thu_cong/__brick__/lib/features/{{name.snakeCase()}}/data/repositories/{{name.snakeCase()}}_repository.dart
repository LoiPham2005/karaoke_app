import '../../../../../../core/base/errors/result.dart';
import '../../../../../../core/data/network/api_client.dart';
import '../models/{{name.snakeCase()}}_model.dart';

class {{name.pascalCase()}}Repository {
  final ApiClient _apiClient;

  {{name.pascalCase()}}Repository(this._apiClient);

  Future<Result<List<{{name.pascalCase()}}Model>>> getList() {
    return _apiClient.get<List<{{name.pascalCase()}}Model>>(
      '/api/{{name.paramCase()}}s',
      (json) => (json as List<dynamic>)
          .map((e) => {{name.pascalCase()}}Model.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<{{name.pascalCase()}}Model>> create({{name.pascalCase()}}Model item) {
    return _apiClient.post<{{name.pascalCase()}}Model>(
      '/api/{{name.paramCase()}}s',
      (json) => {{name.pascalCase()}}Model.fromJson(json as Map<String, dynamic>),
      data: item.toJson(),
    );
  }
}
