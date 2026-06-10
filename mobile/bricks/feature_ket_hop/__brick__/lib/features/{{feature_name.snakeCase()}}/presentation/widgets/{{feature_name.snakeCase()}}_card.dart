import 'package:flutter/material.dart';

import '../../data/models/{{feature_name.snakeCase()}}_model.dart';

class {{feature_name.pascalCase()}}Card extends StatelessWidget {
  final {{feature_name.pascalCase()}}Model {{feature_name.camelCase()}};
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const {{feature_name.pascalCase()}}Card({super.key, required this.{{feature_name.camelCase()}}, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Icon/Image ──
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: {{feature_name.camelCase()}}.iconUrl != null
                    ? Image.network(
                        {{feature_name.camelCase()}}.iconUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 16),

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      {{feature_name.camelCase()}}.{{feature_name.camelCase()}}Name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if ({{feature_name.camelCase()}}.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        {{feature_name.camelCase()}}.description!,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    _buildStatusChip({{feature_name.camelCase()}}.status),
                  ],
                ),
              ),

              // ── Actions ──
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.category, color: Colors.grey),
    );
  }

  Widget _buildStatusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Hoạt động' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }
}
