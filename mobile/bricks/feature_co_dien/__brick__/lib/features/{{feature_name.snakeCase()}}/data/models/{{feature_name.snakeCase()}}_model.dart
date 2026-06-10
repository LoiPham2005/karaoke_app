import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/{{feature_name.snakeCase()}}.dart';

part '{{feature_name.snakeCase()}}_model.g.dart';

/// {{feature_name.pascalCase()}} model
@JsonSerializable()
class {{feature_name.pascalCase()}}Model extends {{feature_name.pascalCase()}} {
  const {{feature_name.pascalCase()}}Model({
    required super.id,
    required super.name,
  });

  /// From JSON
  factory {{feature_name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{feature_name.pascalCase()}}ModelFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _${{feature_name.pascalCase()}}ModelToJson(this);

  /// To Entity
  {{feature_name.pascalCase()}} toEntity() {
    return {{feature_name.pascalCase()}}(
      id: id,
      name: name,
    );
  }

  /// From Entity
  factory {{feature_name.pascalCase()}}Model.fromEntity({{feature_name.pascalCase()}} entity) {
    return {{feature_name.pascalCase()}}Model(
      id: entity.id,
      name: entity.name,
    );
  }

  /// CopyWith
  {{feature_name.pascalCase()}}Model copyWith({
    String? id,
    String? name,
  }) {
    return {{feature_name.pascalCase()}}Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
