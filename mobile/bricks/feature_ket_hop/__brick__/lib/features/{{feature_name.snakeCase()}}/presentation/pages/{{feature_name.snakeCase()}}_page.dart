import 'package:flutter/material.dart';
import 'package:flutter_base/core/di/injection.dart';
import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/{{feature_name.snakeCase()}}_bloc.dart';
import '../bloc/{{feature_name.snakeCase()}}_event.dart';
import '../widgets/{{feature_name.snakeCase()}}_card.dart';
import '../data/models/{{feature_name.snakeCase()}}_model.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{{feature_name.pascalCase()}}Bloc>()..add(const Load{{feature_name.pascalCase()}}s()),
      child: const {{feature_name.pascalCase()}}View(),
    );
  }
}

class {{feature_name.pascalCase()}}View extends StatelessWidget {
  const {{feature_name.pascalCase()}}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{feature_name.pascalCase()}}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<{{feature_name.pascalCase()}}Bloc>().add(const Load{{feature_name.pascalCase()}}s(refresh: true));
            },
          ),
        ],
      ),
      body: BlocConsumer<{{feature_name.pascalCase()}}Bloc, BaseState>(
        listener: (context, state) {
          if (state.isFailure && state.hasError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
          }
          if (state.isSuccess && state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!), backgroundColor: Colors.green));
            context.read<{{feature_name.pascalCase()}}Bloc>().add(const Load{{feature_name.pascalCase()}}s(refresh: true));
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());

          if (state.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.displayMessage,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<{{feature_name.pascalCase()}}Bloc>().add(const Load{{feature_name.pascalCase()}}s(refresh: true)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state.hasData && state.data is List<{{feature_name.pascalCase()}}Model>) {
            final items = state.data as List<{{feature_name.pascalCase()}}Model>;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<{{feature_name.pascalCase()}}Bloc>().add(const Load{{feature_name.pascalCase()}}s(refresh: true));
              },
              child: Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return {{feature_name.pascalCase()}}Card(
                        {{feature_name.camelCase()}}: item,
                        onTap: () {},
                      );
                    },
                  ),
                  if (state.isRefreshing)
                    const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator()),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
