import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base/core/di/injection.dart';
import '../../domain/entities/{{feature_name.snakeCase()}}.dart';
import '../bloc/{{feature_name.snakeCase()}}_bloc.dart';
import '../widgets/{{feature_name.snakeCase()}}_item.dart';
import 'package:flutter_base/core/state/bloc/base_state.dart';

/// {{feature_name.pascalCase()}} page
class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{{feature_name.pascalCase()}}Bloc>(){{#has_list}}
        ..add(const Fetch{{feature_name.pascalCase()}}sEvent()){{/has_list}},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('{{feature_name.titleCase()}}'),
        ),
        body: BlocConsumer<{{feature_name.pascalCase()}}Bloc, BaseState>(
          listener: (context, state) {
            if (state.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Đã xảy ra lỗi'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.isSuccess && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isEmpty) {
              return const Center(child: Text('Không có dữ liệu'));
            }
{{#has_list}}
            if (state.hasData && state.data is List<{{feature_name.pascalCase()}}>) {
              final items = state.data as List<{{feature_name.pascalCase()}}>;
              if (items.isEmpty) {
                return const Center(child: Text('Không có {{feature_name.lowerCase()}} nào'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<{{feature_name.pascalCase()}}Bloc>().add(
                    const Fetch{{feature_name.pascalCase()}}sEvent(refresh: true),
                  );
                },
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return {{feature_name.pascalCase()}}Item(
                      {{feature_name.camelCase()}}: items[index],
                      onTap: () {
                        // TODO: Navigate to detail page
                      },
                    );
                  },
                ),
              );
            }
{{/has_list}}
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
