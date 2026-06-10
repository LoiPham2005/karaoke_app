import 'package:flutter/material.dart';
import '../../domain/entities/{{feature_name.snakeCase()}}.dart';

/// {{feature_name.pascalCase()}} item widget
class {{feature_name.pascalCase()}}Item extends StatelessWidget {
  final {{feature_name.pascalCase()}} {{feature_name.camelCase()}};
  final VoidCallback? onTap;

  const {{feature_name.pascalCase()}}Item({
    super.key,
    required this.{{feature_name.camelCase()}},
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text({{feature_name.camelCase()}}.name),
        subtitle: Text('ID: ${{{feature_name.camelCase()}}.id}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
