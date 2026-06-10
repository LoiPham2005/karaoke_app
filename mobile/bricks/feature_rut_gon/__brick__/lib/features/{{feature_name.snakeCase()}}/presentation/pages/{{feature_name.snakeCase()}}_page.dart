import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import 'package:flutter_base/core/base/di/injection.dart';
import '../../data/models/{{feature_name.snakeCase()}}_model.dart';
import '../cubit/{{feature_name.snakeCase()}}_cubit.dart';
import '../widgets/{{feature_name.snakeCase()}}_card.dart';
import '../widgets/{{feature_name.snakeCase()}}_detail_page.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{{feature_name.pascalCase()}}Cubit>()..load{{feature_name.pascalCase()}}s(),
      child: const _{{feature_name.pascalCase()}}View(),
    );
  }
}

class _{{feature_name.pascalCase()}}View extends StatelessWidget {
  const _{{feature_name.pascalCase()}}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{feature_name.pascalCase()}}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<{{feature_name.pascalCase()}}Cubit>().load{{feature_name.pascalCase()}}s(),
          ),
        ],
      ),
      body: BlocBuilder<{{feature_name.pascalCase()}}Cubit, BaseState>(
        builder: (context, state) {
          return state.whenReady(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            empty: (message) => Center(child: Text(message ?? 'Không có dữ liệu')),
            success: (data, message) {
              final items = data as List<{{feature_name.pascalCase()}}Model>;
              return RefreshIndicator(
                onRefresh: () => context.read<{{feature_name.pascalCase()}}Cubit>().load{{feature_name.pascalCase()}}s(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return {{feature_name.pascalCase()}}Card(
                      item: item,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => {{feature_name.pascalCase()}}DetailPage(item: item),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            failure: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<{{feature_name.pascalCase()}}Cubit>().load{{feature_name.pascalCase()}}s(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
