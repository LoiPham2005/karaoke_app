import '../../../../../core/base/errors/result.dart';
import '../entities/{{feature_name.snakeCase()}}.dart';

abstract class {{feature_name.pascalCase()}}Repository {
  Future<Result<List<{{feature_name.pascalCase()}}>>> get{{feature_name.pascalCase()}}s({Map<String, dynamic>? params});
  Future<Result<{{feature_name.pascalCase()}}>> get{{feature_name.pascalCase()}}Detail(String id);
  Future<Result<{{feature_name.pascalCase()}}>> create{{feature_name.pascalCase()}}(Map<String, dynamic> data);
  Future<Result<{{feature_name.pascalCase()}}>> update{{feature_name.pascalCase()}}(String id, Map<String, dynamic> data);
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id);
}
