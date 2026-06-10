import 'package:freezed_annotation/freezed_annotation.dart';

part '{{name.snakeCase()}}_model.freezed.dart';
part '{{name.snakeCase()}}_model.g.dart';

@freezed
abstract class {{name.pascalCase()}}Model with _${{name.pascalCase()}}Model {
  const factory {{name.pascalCase()}}Model({
    required int id,
    required String name,
    // Add more fields here
  }) = _{{name.pascalCase()}}Model;

  factory {{name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) => _${{name.pascalCase()}}ModelFromJson(json);
}
