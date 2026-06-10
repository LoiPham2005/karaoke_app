import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/base/state/bloc/base_state.dart';
import '../../data/models/{{feature_name.snakeCase()}}_model.dart';
import '../bloc/{{feature_name.snakeCase()}}_bloc.dart';

class {{feature_name.pascalCase()}}DetailPage extends StatelessWidget {
  final String {{feature_name.camelCase()}}Id;

  const {{feature_name.pascalCase()}}DetailPage({super.key, required this.{{feature_name.camelCase()}}Id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết {{feature_name.pascalCase()}}')),
      body: BlocBuilder<{{feature_name.pascalCase()}}Bloc, BaseState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());

          if (state.hasData && state.data is {{feature_name.pascalCase()}}Model) {
            final item = state.data as {{feature_name.pascalCase()}}Model;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.iconUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.iconUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    item.{{feature_name.camelCase()}}Name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 24),
                  _buildRow('Trạng thái', item.status),
                  _buildRow('Thứ tự', item.displayOrder.toString()),
                  _buildRow('Ngày tạo', item.createdAt.toString()),
                ],
              ),
            );
          }

          return const Center(child: Text('Không tìm thấy dữ liệu'));
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
