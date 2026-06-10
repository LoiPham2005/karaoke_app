import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/base/state/bloc/auto_bloc/auto_bloc.dart';
import '../../../../../core/base/state/bloc/base_state.dart';
import '../../data/models/{{name.snakeCase()}}_model.dart';
import '../cubit/{{name.snakeCase()}}_list_cubit.dart';

class {{name.pascalCase()}}ListScreen
    extends CubitPage<{{name.pascalCase()}}ListCubit, List<{{name.pascalCase()}}Model>> {
  const {{name.pascalCase()}}ListScreen({super.key});

  @override
  void onInit({{name.pascalCase()}}ListCubit cubit) => cubit.loadList();

  @override
  Widget buildPage(
    BuildContext context,
    {{name.pascalCase()}}ListCubit cubit,
    BaseState<List<{{name.pascalCase()}}Model>> state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.pascalCase()}}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cubit.refresh(),
          ),
        ],
      ),
      body: state.whenReady(
        loading: (prev) => prev != null
            ? Stack(children: [_List(items: prev), const LinearProgressIndicator()])
            : const Center(child: CircularProgressIndicator()),
        empty: (_) => const Center(child: Text('Không có dữ liệu')),
        failure: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => cubit.loadList(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        success: (data, _) => _List(items: data),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final List<{{name.pascalCase()}}Model> items;
  const _List({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return ListTile(
          title: Text(item.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () =>
                context.read<{{name.pascalCase()}}ListCubit>().delete(item.id),
          ),
        );
      },
    );
  }
}
