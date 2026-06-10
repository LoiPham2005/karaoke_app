import 'package:equatable/equatable.dart';

class {{feature_name.pascalCase()}} extends Equatable {
  final int {{feature_name.camelCase()}}Id;
  final String {{feature_name.camelCase()}}Name;
  final String? description;
  final String? iconUrl;
  final String status;
  final int displayOrder;
  final DateTime createdAt;

  const {{feature_name.pascalCase()}}({
    required this.{{feature_name.camelCase()}}Id,
    required this.{{feature_name.camelCase()}}Name,
    this.description,
    this.iconUrl,
    required this.status,
    required this.displayOrder,
    required this.createdAt,
  });

  {{feature_name.pascalCase()}} copyWith({
    int? {{feature_name.camelCase()}}Id,
    String? {{feature_name.camelCase()}}Name,
    String? description,
    String? iconUrl,
    String? status,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return {{feature_name.pascalCase()}}(
      {{feature_name.camelCase()}}Id: {{feature_name.camelCase()}}Id ?? this.{{feature_name.camelCase()}}Id,
      {{feature_name.camelCase()}}Name: {{feature_name.camelCase()}}Name ?? this.{{feature_name.camelCase()}}Name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      status: status ?? this.status,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    {{feature_name.camelCase()}}Id,
    {{feature_name.camelCase()}}Name,
    description,
    iconUrl,
    status,
    displayOrder,
    createdAt,
  ];

  @override
  String toString() =>
      '{{feature_name.pascalCase()}}({{feature_name.camelCase()}}Id: ${{feature_name.camelCase()}}Id, {{feature_name.camelCase()}}Name: ${{feature_name.camelCase()}}Name, status: $status)';
}
