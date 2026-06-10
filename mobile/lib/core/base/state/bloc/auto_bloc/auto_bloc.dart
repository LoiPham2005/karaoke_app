// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/widgets/auto_bloc.dart
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../base_state.dart';
import '../../../state/cubit/base_cubit.dart';
import 'bloc_manager.dart';

/// 🚀 AutoBloc — Widget tự Register/Dispose BLoC từ GetIt
///
/// Widgets:
/// - `AutoBlocBuilder`       — build UI theo state
/// - `AutoBlocListener`      — side-effects (toast, navigate)
/// - `AutoBlocConsumer`      — builder + listener
/// - `AutoBlocSelector`      — rebuild khi 1 phần state thay đổi
/// - `AutoBlocProvider`      — chỉ cung cấp vào tree
/// - `MultiAutoBlocProvider` — nhiều provider cùng lúc
///
/// Tính năng:
/// - Tự acquire/release qua BlocManager (ref-counting)
/// - Hot-reload safe: re-init khi scopeKey thay đổi
/// - Wrap BlocProvider.value để context.read<T>() hoạt động
///
/// ```dart
/// // Cơ bản
/// AutoBlocBuilder<ProductCubit, BaseState<List<Product>>>(
///   onInit: (bloc) => bloc.loadProducts(),
///   builder: (context, bloc, state) => ProductList(state.data),
/// )
///
/// // Scoped — 2 instance cùng type
/// AutoBlocBuilder<DetailCubit, BaseState<Product>>(
///   scopeKey: 'product_$id',
///   factory:  () => DetailCubit(id: id),
///   onInit:   (bloc) => bloc.load(),
///   builder:  (context, bloc, state) => ...,
/// )
/// ```

// ──────────────────────────────────────────────────────────────
// Base State — loại bỏ duplicate initState/dispose/didUpdateWidget
// ──────────────────────────────────────────────────────────────

abstract class _AutoBlocState<T extends BlocBase<S>, S, W extends StatefulWidget> extends State<W> {
  late T bloc;

  String?          get _scopeKey  => null;
  T Function()?    get _factory   => null;
  void Function(T)? get _onInit   => null;
  void Function(T)? get _onDispose => null;

  T _acquire() => _factory != null
      ? BlocManager.getWith(_factory!, key: _scopeKey)
      : BlocManager.get<T>(key: _scopeKey);

  @override
  void initState() {
    super.initState();
    bloc = _acquire();
    _onInit?.call(bloc);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-init khi scopeKey thay đổi (e.g. navigate từ detail A → detail B)
    if (_didScopeKeyChange(oldWidget)) {
      _onDispose?.call(bloc);
      BlocManager.release<T>(key: _oldScopeKey(oldWidget));
      bloc = _acquire();
      _onInit?.call(bloc);
    }
  }

  @override
  void dispose() {
    _onDispose?.call(bloc);
    BlocManager.release<T>(key: _scopeKey);
    super.dispose();
  }

  // Override trong subclass để trả về scopeKey cũ từ oldWidget
  bool _didScopeKeyChange(W oldWidget) => false;
  String? _oldScopeKey(W oldWidget)    => null;

  /// Wrap child với BlocProvider.value để context.read<T>() hoạt động
  Widget provide(Widget child) => BlocProvider<T>.value(value: bloc, child: child);
}

// ──────────────────────────────────────────────────────────────
// AutoBlocBuilder
// ──────────────────────────────────────────────────────────────

class AutoBlocBuilder<T extends BlocBase<S>, S> extends StatefulWidget {
  final Widget Function(BuildContext, T bloc, S state) builder;
  final BlocBuilderCondition<S>? buildWhen;
  final String?          scopeKey;
  final T Function()?    factory;
  final void Function(T)? onInit;
  final void Function(T)? onDispose;

  const AutoBlocBuilder({
    super.key,
    required this.builder,
    this.buildWhen,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoBlocBuilder<T, S>> createState() => _AutoBlocBuilderState<T, S>();
}

class _AutoBlocBuilderState<T extends BlocBase<S>, S>
    extends _AutoBlocState<T, S, AutoBlocBuilder<T, S>> {
  @override String?           get _scopeKey   => widget.scopeKey;
  @override T Function()?     get _factory    => widget.factory;
  @override void Function(T)? get _onInit     => widget.onInit;
  @override void Function(T)? get _onDispose  => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoBlocBuilder<T, S>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoBlocBuilder<T, S>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocBuilder<T, S>(
      bloc:      bloc,
      buildWhen: widget.buildWhen,
      builder:   (ctx, state) => widget.builder(ctx, bloc, state),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoBlocListener
// ──────────────────────────────────────────────────────────────

class AutoBlocListener<T extends BlocBase<S>, S> extends StatefulWidget {
  final void Function(BuildContext, T bloc, S state) listener;
  final BlocListenerCondition<S>? listenWhen;
  final Widget child;
  final String?          scopeKey;
  final T Function()?    factory;
  final void Function(T)? onInit;
  final void Function(T)? onDispose;

  const AutoBlocListener({
    super.key,
    required this.listener,
    required this.child,
    this.listenWhen,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoBlocListener<T, S>> createState() => _AutoBlocListenerState<T, S>();
}

class _AutoBlocListenerState<T extends BlocBase<S>, S>
    extends _AutoBlocState<T, S, AutoBlocListener<T, S>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override T Function()?     get _factory   => widget.factory;
  @override void Function(T)? get _onInit    => widget.onInit;
  @override void Function(T)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoBlocListener<T, S>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoBlocListener<T, S>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocListener<T, S>(
      bloc:       bloc,
      listenWhen: widget.listenWhen,
      listener:   (ctx, state) => widget.listener(ctx, bloc, state),
      child:      widget.child,
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoBlocConsumer
// ──────────────────────────────────────────────────────────────

class AutoBlocConsumer<T extends BlocBase<S>, S> extends StatefulWidget {
  final Widget Function(BuildContext, T bloc, S state) builder;
  final void Function(BuildContext, T bloc, S state) listener;
  final BlocBuilderCondition<S>?  buildWhen;
  final BlocListenerCondition<S>? listenWhen;
  final String?          scopeKey;
  final T Function()?    factory;
  final void Function(T)? onInit;
  final void Function(T)? onDispose;

  const AutoBlocConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.buildWhen,
    this.listenWhen,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoBlocConsumer<T, S>> createState() => _AutoBlocConsumerState<T, S>();
}

class _AutoBlocConsumerState<T extends BlocBase<S>, S>
    extends _AutoBlocState<T, S, AutoBlocConsumer<T, S>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override T Function()?     get _factory   => widget.factory;
  @override void Function(T)? get _onInit    => widget.onInit;
  @override void Function(T)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoBlocConsumer<T, S>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoBlocConsumer<T, S>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocConsumer<T, S>(
      bloc:       bloc,
      buildWhen:  widget.buildWhen,
      listenWhen: widget.listenWhen,
      builder:    (ctx, state) => widget.builder(ctx, bloc, state),
      listener:   (ctx, state) => widget.listener(ctx, bloc, state),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoBlocSelector
// ──────────────────────────────────────────────────────────────

class AutoBlocSelector<T extends BlocBase<S>, S, V> extends StatefulWidget {
  final BlocWidgetSelector<S, V> selector;
  final Widget Function(BuildContext, V value) builder;
  final String?          scopeKey;
  final T Function()?    factory;
  final void Function(T)? onInit;
  final void Function(T)? onDispose;

  const AutoBlocSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoBlocSelector<T, S, V>> createState() =>
      _AutoBlocSelectorState<T, S, V>();
}

class _AutoBlocSelectorState<T extends BlocBase<S>, S, V>
    extends _AutoBlocState<T, S, AutoBlocSelector<T, S, V>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override T Function()?     get _factory   => widget.factory;
  @override void Function(T)? get _onInit    => widget.onInit;
  @override void Function(T)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoBlocSelector<T, S, V>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoBlocSelector<T, S, V>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocSelector<T, S, V>(
      bloc:     bloc,
      selector: widget.selector,
      builder:  widget.builder,
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoBlocProvider
// ──────────────────────────────────────────────────────────────

class AutoBlocProvider<T extends BlocBase<Object?>> extends StatefulWidget {
  final Widget child;
  final String?          scopeKey;
  final T Function()?    factory;
  final void Function(T)? onInit;
  final void Function(T)? onDispose;

  const AutoBlocProvider({
    super.key,
    required this.child,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoBlocProvider<T>> createState() => _AutoBlocProviderState<T>();
}

class _AutoBlocProviderState<T extends BlocBase<Object?>>
    extends _AutoBlocState<T, Object?, AutoBlocProvider<T>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override T Function()?     get _factory   => widget.factory;
  @override void Function(T)? get _onInit    => widget.onInit;
  @override void Function(T)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoBlocProvider<T>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoBlocProvider<T>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(widget.child);
}

// ──────────────────────────────────────────────────────────────
// MultiAutoBlocProvider
// ──────────────────────────────────────────────────────────────

/// ```dart
/// MultiAutoBlocProvider(
///   providers: [
///     (child) => AutoBlocProvider<AuthCubit>(child: child),
///     (child) => AutoBlocProvider<HomeCubit>(child: child),
///   ],
///   child: MyPage(),
/// )
/// ```
class MultiAutoBlocProvider extends StatelessWidget {
  final List<Widget Function(Widget child)> providers;
  final Widget child;

  const MultiAutoBlocProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) =>
      providers.reversed.fold(child, (child, builder) => builder(child));
}

// ══════════════════════════════════════════════════════════════════
// AutoCubit variants — loại bỏ BaseState<> khỏi type params
//
// Trước: AutoBlocBuilder<MyCubit, BaseState<List<Model>>>(...)
// Sau:   AutoCubitBuilder<MyCubit, List<Model>>(...)
//
// C = Cubit type (extends BaseCubit<D>)
// D = Data type  (model, list, v.v.)
// State type = BaseState<D> — tự suy, không cần khai báo
// ══════════════════════════════════════════════════════════════════

// ──────────────────────────────────────────────────────────────
// AutoCubitBuilder
// ──────────────────────────────────────────────────────────────

class AutoCubitBuilder<C extends BaseCubit<D>, D> extends StatefulWidget {
  final Widget Function(BuildContext context, C cubit, BaseState<D> state) builder;
  final BlocBuilderCondition<BaseState<D>>? buildWhen;
  final String?           scopeKey;
  final C Function()?     factory;
  final void Function(C)? onInit;
  final void Function(C)? onDispose;

  const AutoCubitBuilder({
    super.key,
    required this.builder,
    this.buildWhen,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoCubitBuilder<C, D>> createState() => _AutoCubitBuilderState<C, D>();
}

class _AutoCubitBuilderState<C extends BaseCubit<D>, D>
    extends _AutoBlocState<C, BaseState<D>, AutoCubitBuilder<C, D>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override C Function()?     get _factory   => widget.factory;
  @override void Function(C)? get _onInit    => widget.onInit;
  @override void Function(C)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoCubitBuilder<C, D>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoCubitBuilder<C, D>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocBuilder<C, BaseState<D>>(
      bloc:      bloc,
      buildWhen: widget.buildWhen,
      builder:   (ctx, state) => widget.builder(ctx, bloc, state),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoCubitListener
// ──────────────────────────────────────────────────────────────

class AutoCubitListener<C extends BaseCubit<D>, D> extends StatefulWidget {
  final void Function(BuildContext context, C cubit, BaseState<D> state) listener;
  final BlocListenerCondition<BaseState<D>>? listenWhen;
  final Widget child;
  final String?           scopeKey;
  final C Function()?     factory;
  final void Function(C)? onInit;
  final void Function(C)? onDispose;

  const AutoCubitListener({
    super.key,
    required this.listener,
    required this.child,
    this.listenWhen,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoCubitListener<C, D>> createState() => _AutoCubitListenerState<C, D>();
}

class _AutoCubitListenerState<C extends BaseCubit<D>, D>
    extends _AutoBlocState<C, BaseState<D>, AutoCubitListener<C, D>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override C Function()?     get _factory   => widget.factory;
  @override void Function(C)? get _onInit    => widget.onInit;
  @override void Function(C)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoCubitListener<C, D>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoCubitListener<C, D>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocListener<C, BaseState<D>>(
      bloc:       bloc,
      listenWhen: widget.listenWhen,
      listener:   (ctx, state) => widget.listener(ctx, bloc, state),
      child:      widget.child,
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoCubitConsumer
// ──────────────────────────────────────────────────────────────

class AutoCubitConsumer<C extends BaseCubit<D>, D> extends StatefulWidget {
  final Widget Function(BuildContext context, C cubit, BaseState<D> state) builder;
  final void Function(BuildContext context, C cubit, BaseState<D> state)? listener;
  final BlocBuilderCondition<BaseState<D>>?  buildWhen;
  final BlocListenerCondition<BaseState<D>>? listenWhen;
  final String?           scopeKey;
  final C Function()?     factory;
  final void Function(C)? onInit;
  final void Function(C)? onDispose;

  const AutoCubitConsumer({
    super.key,
    required this.builder,
    this.listener,
    this.buildWhen,
    this.listenWhen,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoCubitConsumer<C, D>> createState() => _AutoCubitConsumerState<C, D>();
}

class _AutoCubitConsumerState<C extends BaseCubit<D>, D>
    extends _AutoBlocState<C, BaseState<D>, AutoCubitConsumer<C, D>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override C Function()?     get _factory   => widget.factory;
  @override void Function(C)? get _onInit    => widget.onInit;
  @override void Function(C)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoCubitConsumer<C, D>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoCubitConsumer<C, D>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocConsumer<C, BaseState<D>>(
      bloc:       bloc,
      buildWhen:  widget.buildWhen,
      listenWhen: widget.listenWhen,
      builder:    (ctx, state) => widget.builder(ctx, bloc, state),
      listener:   (ctx, state) => widget.listener?.call(ctx, bloc, state),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// AutoCubitSelector
// ──────────────────────────────────────────────────────────────

class AutoCubitSelector<C extends BaseCubit<D>, D, V> extends StatefulWidget {
  final BlocWidgetSelector<BaseState<D>, V> selector;
  final Widget Function(BuildContext context, V value) builder;
  final String?           scopeKey;
  final C Function()?     factory;
  final void Function(C)? onInit;
  final void Function(C)? onDispose;

  const AutoCubitSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.scopeKey,
    this.factory,
    this.onInit,
    this.onDispose,
  });

  @override
  State<AutoCubitSelector<C, D, V>> createState() => _AutoCubitSelectorState<C, D, V>();
}

class _AutoCubitSelectorState<C extends BaseCubit<D>, D, V>
    extends _AutoBlocState<C, BaseState<D>, AutoCubitSelector<C, D, V>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override C Function()?     get _factory   => widget.factory;
  @override void Function(C)? get _onInit    => widget.onInit;
  @override void Function(C)? get _onDispose => widget.onDispose;

  @override
  bool _didScopeKeyChange(StatefulWidget old) =>
      (old as AutoCubitSelector<C, D, V>).scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(StatefulWidget old) => (old as AutoCubitSelector<C, D, V>).scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocSelector<C, BaseState<D>, V>(
      bloc:     bloc,
      selector: widget.selector,
      builder:  widget.builder,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
// BlocFamily / CubitFamily — Riverpod-style family params
//
// Thay vì:
//   scopeKey: 'detail_$id',
//   factory:  () => DetailCubit(id: id),
//
// Định nghĩa 1 lần:
//   final detailFamily = CubitFamily<DetailCubit, Product, int>(
//     (id) => DetailCubit(id: id),
//   );
//
// Dùng trong widget:
//   CubitFamilyBuilder(
//     family: detailFamily,
//     param: id,
//     onInit: (c) => c.load(),
//     builder: (ctx, cubit, state) => ...,
//   )
// ══════════════════════════════════════════════════════════════════

/// Định nghĩa một "family" Cubit — tương đương `provider.family` của Riverpod.
///
/// [C] = Cubit type, [D] = Data type, [P] = Param type
class CubitFamily<C extends BaseCubit<D>, D, P> {
  final C Function(P param) create;

  const CubitFamily(this.create);

  String keyFor(P param) => '$C:${param.hashCode}_$param';
}

/// Widget dùng [CubitFamily] — tương đương `ref.watch(provider(param))`.
class CubitFamilyBuilder<C extends BaseCubit<D>, D, P> extends StatelessWidget {
  final CubitFamily<C, D, P> family;
  final P param;
  final Widget Function(BuildContext context, C cubit, BaseState<D> state) builder;
  final BlocBuilderCondition<BaseState<D>>? buildWhen;
  final void Function(C)? onInit;
  final void Function(C)? onDispose;

  const CubitFamilyBuilder({
    super.key,
    required this.family,
    required this.param,
    required this.builder,
    this.buildWhen,
    this.onInit,
    this.onDispose,
  });

  @override
  Widget build(BuildContext context) => AutoCubitBuilder<C, D>(
    scopeKey: family.keyFor(param),
    factory:  () => family.create(param),
    onInit:   onInit,
    onDispose: onDispose,
    buildWhen: buildWhen,
    builder:   builder,
  );
}

/// Variant cho Bloc (không phải Cubit).
///
/// [B] = Bloc type, [S] = State type, [P] = Param type
class BlocFamily<B extends BlocBase<S>, S, P> {
  final B Function(P param) create;

  const BlocFamily(this.create);

  String keyFor(P param) => '$B:${param.hashCode}_$param';
}

class BlocFamilyBuilder<B extends BlocBase<S>, S, P> extends StatelessWidget {
  final BlocFamily<B, S, P> family;
  final P param;
  final Widget Function(BuildContext context, B bloc, S state) builder;
  final BlocBuilderCondition<S>? buildWhen;
  final void Function(B)? onInit;
  final void Function(B)? onDispose;

  const BlocFamilyBuilder({
    super.key,
    required this.family,
    required this.param,
    required this.builder,
    this.buildWhen,
    this.onInit,
    this.onDispose,
  });

  @override
  Widget build(BuildContext context) => AutoBlocBuilder<B, S>(
    scopeKey: family.keyFor(param),
    factory:  () => family.create(param),
    onInit:   onInit,
    onDispose: onDispose,
    buildWhen: buildWhen,
    builder:   builder,
  );
}

// ══════════════════════════════════════════════════════════════════
// CubitPage — Riverpod-style abstract class
//
// Thay vì dùng AutoCubitConsumer trong build(), kế thừa CubitPage
// và override buildPage() + onInit() — giống ConsumerWidget của Riverpod.
//
// ```dart
// class ProductListScreen extends CubitPage<ProductListGenCubit, List<ProductModelGen>> {
//   const ProductListScreen({super.key});
//
//   @override
//   void onInit(ProductListGenCubit cubit) => cubit.loadProducts();
//
//   @override
//   Widget buildPage(BuildContext ctx, ProductListGenCubit cubit,
//       BaseState<List<ProductModelGen>> state) {
//     return Scaffold(
//       body: state.whenReady(
//         loading: (_)       => const CircularProgressIndicator(),
//         success: (data, _)  => ProductList(data),
//         empty:   (_)        => const Text('Trống'),
//         failure: (err, _)   => Text(err),
//       ),
//     );
//   }
// }
// ```
// ══════════════════════════════════════════════════════════════════

abstract class CubitPage<C extends BaseCubit<D>, D> extends StatefulWidget {
  const CubitPage({super.key});

  // Override để tuỳ chỉnh scope / factory
  String?       get scopeKey => null;
  C Function()? get factory  => null;

  // Lifecycle hooks
  void onInit(C cubit)                  {}
  void onDispose(C cubit)               {}
  void onDidChangeDependencies(C cubit) {}

  // Override bắt buộc — build UI
  Widget buildPage(BuildContext context, C cubit, BaseState<D> state);

  // Override tuỳ chọn — side-effects (toast, navigation...)
  void onListen(BuildContext context, C cubit, BaseState<D> state) {}
  bool listenWhen(BaseState<D> previous, BaseState<D> current) => previous != current;

  @override
  State<CubitPage<C, D>> createState() => _CubitPageState<C, D>();
}

class _CubitPageState<C extends BaseCubit<D>, D>
    extends _AutoBlocState<C, BaseState<D>, CubitPage<C, D>> {
  @override String?           get _scopeKey  => widget.scopeKey;
  @override C Function()?     get _factory   => widget.factory;
  @override void Function(C)? get _onInit    => widget.onInit;
  @override void Function(C)? get _onDispose => widget.onDispose;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onDidChangeDependencies(bloc);
  }

  @override
  bool _didScopeKeyChange(CubitPage<C, D> oldWidget) =>
      oldWidget.scopeKey != widget.scopeKey;

  @override
  String? _oldScopeKey(CubitPage<C, D> oldWidget) => oldWidget.scopeKey;

  @override
  Widget build(BuildContext context) => provide(
    BlocConsumer<C, BaseState<D>>(
      bloc:       bloc,
      listenWhen: widget.listenWhen,
      listener:   (ctx, state) => widget.onListen(ctx, bloc, state),
      builder:    (ctx, state) => widget.buildPage(ctx, bloc, state),
    ),
  );
}
