import 'package:flutter_base/core/errors/result.dart';
import '../entities/{{feature_name.snakeCase()}}.dart';

/// {{feature_name.pascalCase()}} repository abstract
abstract class {{feature_name.pascalCase()}}Repository {
{{#has_list}}
  /// Get all {{feature_name.lowerCase()}}s
  Future<Result<List<{{feature_name.pascalCase()}}>>> get{{feature_name.pascalCase()}}s({
    Map<String, dynamic>? params,
  });
{{/has_list}}

{{#has_detail}}
  /// Get {{feature_name.lowerCase()}} detail
  Future<Result<{{feature_name.pascalCase()}}>> get{{feature_name.pascalCase()}}Detail(String id);
{{/has_detail}}

{{#has_create}}
  /// Create new {{feature_name.lowerCase()}}
  Future<Result<{{feature_name.pascalCase()}}>> create{{feature_name.pascalCase()}}(
    Map<String, dynamic> data,
  );
{{/has_create}}

{{#has_update}}
  /// Update {{feature_name.lowerCase()}}
  Future<Result<{{feature_name.pascalCase()}}>> update{{feature_name.pascalCase()}}(
    String id,
    Map<String, dynamic> data,
  );
{{/has_update}}

{{#has_delete}}
  /// Delete {{feature_name.lowerCase()}}
  Future<Result<bool>> delete{{feature_name.pascalCase()}}(String id);
{{/has_delete}}
}
