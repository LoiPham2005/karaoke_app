import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '{{feature_name.snakeCase()}}_model.g.dart';

@JsonSerializable()
class {{feature_name.pascalCase()}}Model extends Equatable {
  final int id;
  final String name;

  const {{feature_name.pascalCase()}}Model({
    required this.id,
    required this.name,
  });

  factory {{feature_name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{feature_name.pascalCase()}}ModelFromJson(json);

  Map<String, dynamic> toJson() => _${{feature_name.pascalCase()}}ModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}
