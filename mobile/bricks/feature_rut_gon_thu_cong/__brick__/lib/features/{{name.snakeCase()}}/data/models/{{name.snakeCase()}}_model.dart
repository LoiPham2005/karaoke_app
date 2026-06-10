class {{name.pascalCase()}}Model {
  final int id;
  final String name;

  const {{name.pascalCase()}}Model({
    required this.id,
    required this.name,
  });

  factory {{name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) {
    return {{name.pascalCase()}}Model(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  {{name.pascalCase()}}Model copyWith({
    int? id,
    String? name,
  }) {
    return {{name.pascalCase()}}Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
