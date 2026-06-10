import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/{{feature_name.snakeCase()}}.dart';

part '{{feature_name.snakeCase()}}_model.g.dart';

@JsonSerializable()
class {{feature_name.pascalCase()}}Model {
  final int {{feature_name.camelCase()}}Id;
  final String {{feature_name.camelCase()}}Name;
  final String? description;
  final String? iconUrl;
  final String status;
  final int displayOrder;
  final DateTime createdAt;

  const {{feature_name.pascalCase()}}Model({
    required this.{{feature_name.camelCase()}}Id,
    required this.{{feature_name.camelCase()}}Name,
    this.description,
    this.iconUrl,
    required this.status,
    required this.displayOrder,
    required this.createdAt,
  });

  factory {{feature_name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) => _${{feature_name.pascalCase()}}ModelFromJson(json);

  Map<String, dynamic> toJson() => _${{feature_name.pascalCase()}}ModelToJson(this);

  /// Model → Entity
  {{feature_name.pascalCase()}} toEntity() => {{feature_name.pascalCase()}}(
    {{feature_name.camelCase()}}Id: {{feature_name.camelCase()}}Id,
    {{feature_name.camelCase()}}Name: {{feature_name.camelCase()}}Name,
    description: description,
    iconUrl: iconUrl,
    status: status,
    displayOrder: displayOrder,
    createdAt: createdAt,
  );

  /// Entity → Model
  factory {{feature_name.pascalCase()}}Model.fromEntity({{feature_name.pascalCase()}} entity) => {{feature_name.pascalCase()}}Model(
    {{feature_name.camelCase()}}Id: entity.{{feature_name.camelCase()}}Id,
    {{feature_name.camelCase()}}Name: entity.{{feature_name.camelCase()}}Name,
    description: entity.description,
    iconUrl: entity.iconUrl,
    status: entity.status,
    displayOrder: entity.displayOrder,
    createdAt: entity.createdAt,
  );

  @override
  String toString() =>
      '{{feature_name.pascalCase()}}Model({{feature_name.camelCase()}}Id: ${{feature_name.camelCase()}}Id, {{feature_name.camelCase()}}Name: ${{feature_name.camelCase()}}Name, status: $status)';
}
