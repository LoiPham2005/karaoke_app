import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import '../../data/models/{{feature_name.snakeCase()}}_model.dart';
import '../cubit/{{feature_name.snakeCase()}}_cubit.dart';

/// 📄 Detail page — nhận item đã load sẵn từ list page
class {{feature_name.pascalCase()}}DetailPage extends StatelessWidget {
  final {{feature_name.pascalCase()}}Model item;

  const {{feature_name.pascalCase()}}DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRow(context, 'ID', item.id.toString()),
                    _buildRow(context, 'Tên', item.name),
                    // TODO: Thêm các field khác theo model
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
          ),
        ],
      ),
    );
  }
}
