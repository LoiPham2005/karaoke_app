import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import 'package:flutter_base/core/base/state/cubit/base_cubit.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/{{feature_name.snakeCase()}}_model.dart';
import '../../data/repositories/{{feature_name.snakeCase()}}_repository.dart';

@injectable
class {{feature_name.pascalCase()}}Cubit extends BaseCubit<List<{{feature_name.pascalCase()}}Model>> {
  final {{feature_name.pascalCase()}}Repository _repository;

  {{feature_name.pascalCase()}}Cubit(this._repository) : super(BaseState.initial());

  /// 📥 Load List
  Future<void> load{{feature_name.pascalCase()}}s({Map<String, dynamic>? params}) async {
    await run(action: () => _repository.get{{feature_name.pascalCase()}}s(params: params));
  }

  /// ➕ Create
  // Future<void> create{{feature_name.pascalCase()}}({{feature_name.pascalCase()}}Model item) async {
  //   await run<{{feature_name.pascalCase()}}Model>(
  //     action: () => _repository.create{{feature_name.pascalCase()}}(item),
  //     // 🎯 Mapper: Thêm item mới vào list hiện tại trong state
  //     mapper: (newItem) => [...(state.data ?? []), newItem],
  //     successMessage: 'Thêm thành công',
  //   );
  // }

  /// ✏️ Update
  // Future<void> update{{feature_name.pascalCase()}}(String id, {{feature_name.pascalCase()}}Model item) async {
  //   await run<{{feature_name.pascalCase()}}Model>(
  //     action: () => _repository.update{{feature_name.pascalCase()}}(id, item),
  //     // 🎯 Mapper: Tìm và thay thế item trong list hiện tại
  //     mapper: (updatedItem) {
  //       final currentList = List<{{feature_name.pascalCase()}}Model>.from(state.data ?? []);
  //       final index = currentList.indexWhere((e) => e.id == id);
  //       if (index != -1) currentList[index] = updatedItem;
  //       return currentList;
  //     },
  //     successMessage: 'Cập nhật thành công',
  //   );
  // }

  /// 🗑️ Delete
  // Future<void> delete{{feature_name.pascalCase()}}(String id) async {
  //   await run<bool>(
  //     action: () => _repository.delete{{feature_name.pascalCase()}}(id),
  //     // 🎯 Mapper: Lọc bỏ item đã xóa khỏi list hiện tại
  //     mapper: (_) {
  //       final currentList = List<{{feature_name.pascalCase()}}Model>.from(state.data ?? []);
  //       currentList.removeWhere((e) => e.id == id.toString());
  //       return currentList;
  //     },
  //     successMessage: 'Xóa thành công',
  //   );
  // }
}
