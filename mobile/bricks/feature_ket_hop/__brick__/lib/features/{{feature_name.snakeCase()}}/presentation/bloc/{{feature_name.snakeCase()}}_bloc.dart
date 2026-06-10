import 'package:flutter_base/core/base/state/bloc/base_bloc.dart';
import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import '{{feature_name.snakeCase()}}_event.dart';

@injectable
class {{feature_name.pascalCase()}}Bloc extends BaseBloc {
  final {{feature_name.pascalCase()}}Repository _repository;

  {{feature_name.pascalCase()}}Bloc(this._repository) : super(BaseState.initial()) {
    on<Load{{feature_name.pascalCase()}}s>(_onLoad{{feature_name.pascalCase()}}s);
  }

  Future<void> _onLoad{{feature_name.pascalCase()}}s(Load{{feature_name.pascalCase()}}s event, Emitter<BaseState> emit) async {
    await run(
      emit: emit,
      action: () => _repository.get{{feature_name.pascalCase()}}s(params: event.params),
    );
  }
}
