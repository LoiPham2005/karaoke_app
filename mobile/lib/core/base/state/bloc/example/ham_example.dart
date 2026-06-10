// // ════════════════════════════════════════════════════════════════
// // USAGE EXAMPLES
// // ════════════════════════════════════════════════════════════════

// // ──────────────────────────────────────────────────────────────
// // CUBIT — Gọi thẳng Service (không cần Repository)
// // ──────────────────────────────────────────────────────────────

// import 'package:flutter_base/core/base/state/bloc/base_event.dart';
// import 'package:flutter_base/core/base/state/bloc/base_state.dart';
// import 'package:flutter_base/core/base/state/bloc/bloc.dart';
// import 'package:flutter_base/features/example/category_ket_hop/data/models/category_model.dart';
// import 'package:flutter_base/features/example/category_ket_hop/domain/repositories/category_repository.dart';
// import 'package:injectable/injectable.dart';

// import '../../../../../features/example/product_rut_gon_thu_cong/data/models/product_model.dart';
// import '../../cubit/base_cubit.dart';

// @injectable
// class ProductCubit extends BaseCubit<List<ProductModel>> {
//   final ProductService _service;
//   ProductCubit(this._service) : super(BaseState.initial());

//   // ✅ runService — gọi Retrofit trực tiếp, tự wrap try/catch
//   Future<void> loadProducts() => runService(action: () => _service.getProducts(null));

//   Future<void> createProduct(ProductModel body) => runService<ProductModel>(
//     action: () => _service.create(body),
//     mapper: (newItem) => [...(state.data ?? []), newItem],
//     successMessage: 'Tạo thành công',
//   );

//   Future<void> updateProduct(int id, ProductModel body) => runService<ProductModel>(
//     action: () => _service.update(id, body),
//     mapper: (updated) => (state.data ?? []).map((e) => e.id == id ? updated : e).toList(),
//     successMessage: 'Cập nhật thành công',
//   );

//   Future<void> deleteProduct(int id) => runService<void>(
//     action: () => _service.delete(id),
//     mapper: (_) => (state.data ?? []).where((e) => e.id != id).toList(),
//     successMessage: 'Xóa thành công',
//   );
// }

// // ──────────────────────────────────────────────────────────────
// // CUBIT — Dùng Repository (khi cần cache / multi-source)
// // ──────────────────────────────────────────────────────────────

// @injectable
// class CategoryCubit extends BaseCubit<List<CategoryModel>> {
//   final CategoryRepository _repo;
//   CategoryCubit(this._repo) : super(BaseState.initial());

//   // ✅ run — repo trả về Result<T>, BaseCubit tự fold
//   Future<void> loadCategories() => run(action: () => _repo.getCategories());

//   Future<void> deleteCategory(String id) => run<bool>(
//     action: () => _repo.deleteCategory(id),
//     mapper: (_) => (state.data ?? []).where((e) => e.id != id).toList(),
//     successMessage: 'Xóa thành công',
//   );
// }

// // ──────────────────────────────────────────────────────────────
// // BLOC — Gọi thẳng Service
// // ──────────────────────────────────────────────────────────────

// // Events
// class LoadProductsEvent extends BaseEvent {}

// class CreateProductEvent extends BaseEvent {
//   final ProductModel product;
//   const CreateProductEvent(this.product);
//   @override
//   List<Object?> get props => [product];
// }

// // Bloc
// @injectable
// class ProductBloc extends BaseBloc<BaseEvent, List<ProductModel>> {
//   final ProductService _service;

//   ProductBloc(this._service) : super(BaseState.initial()) {
//     on<LoadProductsEvent>(_onLoad);
//     on<CreateProductEvent>(_onCreate);
//   }

//   Future<void> _onLoad(LoadProductsEvent event, Emitter emit) =>
//       runService(emit: emit, action: () => _service.getProducts(null));

//   Future<void> _onCreate(CreateProductEvent event, Emitter emit) => runService<ProductModel>(
//     emit: emit,
//     action: () => _service.create(event.product),
//     mapper: (newItem) => [...(state.data ?? []), newItem],
//     successMessage: 'Tạo thành công',
//   );
// }

// // ──────────────────────────────────────────────────────────────
// // So sánh trước / sau
// // ──────────────────────────────────────────────────────────────

// // ❌ TRƯỚC — phải viết try/catch + Result ở khắp nơi
// Future<void> loadProductsBefore() async {
//   emit(BaseState.loading());
//   try {
//     final result = await _repo.getProducts(); // Repository
//     result.fold(
//       onSuccess: (data) => emit(BaseState.success(data: data)),
//       onFailure: (f) => emit(BaseState.failure(error: f.message)),
//     );
//   } catch (e) {
//     emit(BaseState.failure(error: e.toString()));
//   }
// }

// // ✅ SAU — 1 dòng, không try/catch, không Result, không Repository
// Future<void> loadProductsAfter() => runService(action: () => _service.getProducts(null));
