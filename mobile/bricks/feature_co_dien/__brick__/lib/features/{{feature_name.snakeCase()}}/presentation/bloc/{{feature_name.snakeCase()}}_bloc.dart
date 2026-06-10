// ════════════════════════════════════════════════════════════════
// 📁 bricks/feature/__brick__/lib/features/{{feature_name.snakeCase()}}/presentation/bloc/{{feature_name.snakeCase()}}_bloc.dart (FIXED)
// ════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_base/core/state/bloc/base_event.dart';
import 'package:flutter_base/core/state/bloc/base_state.dart';
import 'package:flutter_base/core/state/bloc/base_bloc.dart';
import 'package:flutter_base/core/utils/logger.dart';
import '../../domain/entities/{{feature_name.snakeCase()}}.dart';
import '../../domain/usecases/{{feature_name.snakeCase()}}_usecases.dart';

// ════════════════════════════════════════════════════════════════
// EVENTS
// ════════════════════════════════════════════════════════════════

{{#has_list}}
/// Fetch {{feature_name.lowerCase()}}s list
class Fetch{{feature_name.pascalCase()}}sEvent extends BaseEvent {
  final Map<String, dynamic>? params;
  final bool refresh;

  const Fetch{{feature_name.pascalCase()}}sEvent({
    this.params,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [params, refresh];
}
{{/has_list}}

{{#has_detail}}
/// Fetch {{feature_name.lowerCase()}} detail
class Fetch{{feature_name.pascalCase()}}DetailEvent extends BaseEvent {
  final String id;

  const Fetch{{feature_name.pascalCase()}}DetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}
{{/has_detail}}

{{#has_create}}
/// Create {{feature_name.lowerCase()}}
class Create{{feature_name.pascalCase()}}Event extends BaseEvent {
  final Map<String, dynamic> data;

  const Create{{feature_name.pascalCase()}}Event(this.data);

  @override
  List<Object?> get props => [data];
}
{{/has_create}}

{{#has_update}}
/// Update {{feature_name.lowerCase()}}
class Update{{feature_name.pascalCase()}}Event extends BaseEvent {
  final String id;
  final Map<String, dynamic> data;

  const Update{{feature_name.pascalCase()}}Event(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}
{{/has_update}}

{{#has_delete}}
/// Delete {{feature_name.lowerCase()}}
class Delete{{feature_name.pascalCase()}}Event extends BaseEvent {
  final String id;

  const Delete{{feature_name.pascalCase()}}Event(this.id);

  @override
  List<Object?> get props => [id];
}
{{/has_delete}}

// ════════════════════════════════════════════════════════════════
// BLOC
// ════════════════════════════════════════════════════════════════

@injectable
class {{feature_name.pascalCase()}}Bloc extends BaseBloc {
  {{#has_list}}final Get{{feature_name.pascalCase()}}sUseCase _get{{feature_name.pascalCase()}}sUseCase;{{/has_list}}
  {{#has_detail}}final Get{{feature_name.pascalCase()}}DetailUseCase _get{{feature_name.pascalCase()}}DetailUseCase;{{/has_detail}}
  {{#has_create}}final Create{{feature_name.pascalCase()}}UseCase _create{{feature_name.pascalCase()}}UseCase;{{/has_create}}
  {{#has_update}}final Update{{feature_name.pascalCase()}}UseCase _update{{feature_name.pascalCase()}}UseCase;{{/has_update}}
  {{#has_delete}}final Delete{{feature_name.pascalCase()}}UseCase _delete{{feature_name.pascalCase()}}UseCase;{{/has_delete}}

  {{feature_name.pascalCase()}}Bloc({
    {{#has_list}}required Get{{feature_name.pascalCase()}}sUseCase get{{feature_name.pascalCase()}}sUseCase,{{/has_list}}
    {{#has_detail}}required Get{{feature_name.pascalCase()}}DetailUseCase get{{feature_name.pascalCase()}}DetailUseCase,{{/has_detail}}
    {{#has_create}}required Create{{feature_name.pascalCase()}}UseCase create{{feature_name.pascalCase()}}UseCase,{{/has_create}}
    {{#has_update}}required Update{{feature_name.pascalCase()}}UseCase update{{feature_name.pascalCase()}}UseCase,{{/has_update}}
    {{#has_delete}}required Delete{{feature_name.pascalCase()}}UseCase delete{{feature_name.pascalCase()}}UseCase,{{/has_delete}}
  }) : {{#has_list}}_get{{feature_name.pascalCase()}}sUseCase = get{{feature_name.pascalCase()}}sUseCase,{{/has_list}}
       {{#has_detail}}_get{{feature_name.pascalCase()}}DetailUseCase = get{{feature_name.pascalCase()}}DetailUseCase,{{/has_detail}}
       {{#has_create}}_create{{feature_name.pascalCase()}}UseCase = create{{feature_name.pascalCase()}}UseCase,{{/has_create}}
       {{#has_update}}_update{{feature_name.pascalCase()}}UseCase = update{{feature_name.pascalCase()}}UseCase,{{/has_update}}
       {{#has_delete}}_delete{{feature_name.pascalCase()}}UseCase = delete{{feature_name.pascalCase()}}UseCase,{{/has_delete}}
       super(BaseState.initial()) {
    {{#has_list}}on<Fetch{{feature_name.pascalCase()}}sEvent>(_onFetch{{feature_name.pascalCase()}}s);{{/has_list}}
    {{#has_detail}}on<Fetch{{feature_name.pascalCase()}}DetailEvent>(_onFetch{{feature_name.pascalCase()}}Detail);{{/has_detail}}
    {{#has_create}}on<Create{{feature_name.pascalCase()}}Event>(_onCreate{{feature_name.pascalCase()}});{{/has_create}}
    {{#has_update}}on<Update{{feature_name.pascalCase()}}Event>(_onUpdate{{feature_name.pascalCase()}});{{/has_update}}
    {{#has_delete}}on<Delete{{feature_name.pascalCase()}}Event>(_onDelete{{feature_name.pascalCase()}});{{/has_delete}}
  }

  {{#has_list}}
  /// ✅ Fetch {{feature_name.lowerCase()}}s - dùng run() hoặc runRefresh()
  Future<void> _onFetch{{feature_name.pascalCase()}}s(
    Fetch{{feature_name.pascalCase()}}sEvent event,
    Emitter<BaseState> emit,
  ) async {
    if (event.refresh) {
      // Pull-to-refresh
      await runRefresh<List<{{feature_name.pascalCase()}}>>(
        event: event,
        emit: emit,
        action: () => _get{{feature_name.pascalCase()}}sUseCase(params: event.params),
        onSuccess: (data) {
          Logger.info('✅ Loaded {{feature_name.lowerCase()}}s: ${data.length} items');
        },
        onFailure: (failure) {
          Logger.error('❌ Failed to load {{feature_name.lowerCase()}}s', error: failure.message);
        },
      );
    } else {
      // Initial load
      await run<List<{{feature_name.pascalCase()}}>>(
        event: event,
        emit: emit,
        action: () => _get{{feature_name.pascalCase()}}sUseCase(params: event.params),
        onSuccess: (data) {
          Logger.info('✅ Loaded {{feature_name.lowerCase()}}s: ${data.length} items');
        },
        onFailure: (failure) {
          Logger.error('❌ Failed to load {{feature_name.lowerCase()}}s', error: failure.message);
        },
      );
    }
  }
  {{/has_list}}

  {{#has_detail}}
  /// ✅ Fetch {{feature_name.lowerCase()}} detail
  Future<void> _onFetch{{feature_name.pascalCase()}}Detail(
    Fetch{{feature_name.pascalCase()}}DetailEvent event,
    Emitter<BaseState> emit,
  ) async {
    await run<{{feature_name.pascalCase()}}>(
      event: event,
      emit: emit,
      action: () => _get{{feature_name.pascalCase()}}DetailUseCase(event.id),
      onSuccess: (data) {
        Logger.info('✅ Loaded {{feature_name.lowerCase()}} detail');
      },
      onFailure: (failure) {
        Logger.error('❌ Failed to load {{feature_name.lowerCase()}} detail', error: failure.message);
      },
    );
  }
  {{/has_detail}}

  {{#has_create}}
  /// ✅ Create {{feature_name.lowerCase()}} - dùng runMutation()
  Future<void> _onCreate{{feature_name.pascalCase()}}(
    Create{{feature_name.pascalCase()}}Event event,
    Emitter<BaseState> emit,
  ) async {
    await runMutation<{{feature_name.pascalCase()}}>(
      event: event,
      emit: emit,
      action: () => _create{{feature_name.pascalCase()}}UseCase(event.data),
      successMessage: '{{feature_name.titleCase()}} created successfully',
      onSuccess: (data) {
        Logger.success('✅ {{feature_name.titleCase()}} created');
      },
      onFailure: (failure) {
        Logger.error('❌ Failed to create {{feature_name.lowerCase()}}', error: failure.message);
      },
    );
  }
  {{/has_create}}

  {{#has_update}}
  /// ✅ Update {{feature_name.lowerCase()}} - dùng runMutation()
  Future<void> _onUpdate{{feature_name.pascalCase()}}(
    Update{{feature_name.pascalCase()}}Event event,
    Emitter<BaseState> emit,
  ) async {
    await runMutation<{{feature_name.pascalCase()}}>(
      event: event,
      emit: emit,
      action: () => _update{{feature_name.pascalCase()}}UseCase(event.id, event.data),
      successMessage: '{{feature_name.titleCase()}} updated successfully',
      onSuccess: (data) {
        Logger.success('✅ {{feature_name.titleCase()}} updated');
      },
      onFailure: (failure) {
        Logger.error('❌ Failed to update {{feature_name.lowerCase()}}', error: failure.message);
      },
    );
  }
  {{/has_update}}

  {{#has_delete}}
  /// ✅ Delete {{feature_name.lowerCase()}} - dùng runMutation()
  Future<void> _onDelete{{feature_name.pascalCase()}}(
    Delete{{feature_name.pascalCase()}}Event event,
    Emitter<BaseState> emit,
  ) async {
    await runMutation<bool>(
      event: event,
      emit: emit,
      action: () => _delete{{feature_name.pascalCase()}}UseCase(event.id),
      successMessage: '{{feature_name.titleCase()}} deleted successfully',
      onSuccess: (_) {
        Logger.success('✅ {{feature_name.titleCase()}} deleted');
      },
      onFailure: (failure) {
        Logger.error('❌ Failed to delete {{feature_name.lowerCase()}}', error: failure.message);
      },
    );
  }
  {{/has_delete}}
}
