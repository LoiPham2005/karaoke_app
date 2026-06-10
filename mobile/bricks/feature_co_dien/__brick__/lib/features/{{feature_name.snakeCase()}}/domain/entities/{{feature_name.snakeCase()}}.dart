import 'package:equatable/equatable.dart';

/// {{feature_name.pascalCase()}} entity
class {{feature_name.pascalCase()}} extends Equatable {
  final String id;
  final String name;
  // TODO: Add other properties

  const {{feature_name.pascalCase()}}({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  @override
  String toString() => '{{feature_name.pascalCase()}}(id: $id, name: $name)';
}
