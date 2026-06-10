# 🎯 BLOC & CUBIT BASE CONFIGURATION

Hệ thống base configuration hoàn chỉnh cho Bloc và Cubit trong dự án Flutter.

## 📁 Cấu trúc thư mục

```
lib/core/state/
├── bloc/
│   ├── base_bloc.dart                 # Base class cho Bloc
│   ├── base_event.dart                # Base class cho Events
│   ├── base_state.dart                # Base State với BaseStatus
│   ├── bloc_extensions.dart           # Extension methods
│   ├── bloc_listeners.dart            # Reusable listeners
│   ├── bloc.dart                      # ⭐ Barrel file
│   ├── BLOC_CUBIT_GUIDE.md           # 📚 Documentation
│   └── example/
│       └── bloc_example.dart          # Examples
├── cubit/
│   ├── base_cubit.dart                # Base class cho Cubit
│   ├── cubit_extensions.dart          # Extension methods
│   ├── cubit_listeners.dart           # Reusable listeners
│   ├── cubit.dart                     # ⭐ Barrel file
│   └── example/
│       └── cubit_example.dart         # Examples
└── base_status.dart                   # Shared BaseStatus enum
```

## 🚀 Quick Start

### 1. Import base configuration

```dart
// Cho Bloc
import 'package:flutter_base_template/core/state/bloc/bloc.dart';

// Cho Cubit
import 'package:flutter_base_template/core/state/cubit/cubit.dart';
```

### 2. Tạo Bloc

```dart
import 'package:flutter_base_template/core/state/bloc/bloc.dart';

// Events
class LoadItemsEvent extends BaseEvent {}
class CreateItemEvent extends BaseEvent {
  final Item item;
  const CreateItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// Bloc
class ItemBloc extends BaseBloc {
  final ItemRepository _repository;

  ItemBloc(this._repository) : super(BaseState.initial()) {
    on<LoadItemsEvent>(_onLoadItems);
    on<CreateItemEvent>(_onCreateItem);
  }

  Future<void> _onLoadItems(LoadItemsEvent event, Emitter<BaseState> emit) async {
    await onQuery(
      emit: emit,
      action: () => _repository.getItems(),
    );
  }

  Future<void> _onCreateItem(CreateItemEvent event, Emitter<BaseState> emit) async {
    await onMutation(
      emit: emit,
      action: () => _repository.createItem(event.item),
      successMessage: 'Tạo thành công',
      onSuccess: (_) => add(LoadItemsEvent()),
    );
  }
}
```

### 3. Tạo Cubit

```dart
import 'package:flutter_base_template/core/state/cubit/cubit.dart';

class ItemCubit extends BaseCubit<List<Item>> {
  final ItemRepository _repository;

  ItemCubit(this._repository) : super(BaseState.initial());

  Future<void> loadItems() async {
    await onQuery(
      action: () => _repository.getItems(),
    );
  }

  Future<void> createItem(Item item) async {
    await onMutation(
      action: () => _repository.createItem(item),
      successMessage: 'Tạo thành công',
      onSuccess: (_) => loadItems(),
    );
  }
}
```

### 4. Sử dụng trong UI

```dart
// Bloc
BlocProvider(
  create: (context) => ItemBloc(repository)..add(LoadItemsEvent()),
  child: BlocBuilder<ItemBloc, BaseState<List<Item>>>(
    builder: (context, state) {
      if (state.isLoading) return CircularProgressIndicator();
      if (state.isFailure) return Text('Error: ${state.error}');
      if (state.isEmpty) return Text('No items');

      return ListView.builder(
        itemCount: state.data!.length,
        itemBuilder: (context, index) => ItemTile(state.data![index]),
      );
    },
  ),
)

// Cubit
BlocProvider(
  create: (context) => ItemCubit(repository)..loadItems(),
  child: BlocBuilder<ItemCubit, BaseState<List<Item>>>(
    builder: (context, state) {
      // Same as above
    },
  ),
)
```

## 🎯 Key Features

### 1. **Smart Auto-Detection**

```dart
// Auto-detect mutation mode
await run(
  action: () => repository.createItem(item),
  successMessage: 'Created!',  // → Mutation mode
);

// Auto-detect refresh mode
await onQuery(
  action: () => repository.getData(),
  // Has data → Refreshing
  // No data → Loading
);
```

### 2. **Auto Cancel Queries**

```dart
// Old queries auto-cancelled
await onQuery(
  action: () => repository.search(query),
  cancelPrevious: true,  // Default
);
```

### 3. **Preserve Data on Error**

```dart
// Keep old data when mutation fails
await onMutation(
  action: () => repository.updateItem(item),
  // Auto preserve data
);
```

### 4. **Pagination Support**

```dart
await runPagination(
  action: () async {
    final newItems = await repository.getMore(page: nextPage);
    return newItems.map((items) => [...currentItems, ...items]);
  },
);
```

## 📚 Available Methods

### BaseBloc / BaseCubit

| Method | Purpose | Use Case |
|--------|---------|----------|
| `onQuery()` | Fetch data (GET) | Load list, get details |
| `onMutation()` | Change data (POST/PUT/DELETE) | Create, update, delete |
| `run()` | Generic execution | Custom logic |
| `runPagination()` | Load more data | Infinite scroll |
| `run()` | Flexible execution | No Result pattern |
| `cancelCurrentOperation()` | Cancel query | Search debounce |

### BaseState

| Property | Type | Description |
|----------|------|-------------|
| `status` | `BaseStatus` | Current status |
| `data` | `T?` | Data payload |
| `error` | `String?` | Error message |
| `message` | `String?` | Success message |
| `isLoading` | `bool` | Is loading |
| `isLoaded` | `bool` | Is loaded |
| `isFailure` | `bool` | Has error |
| `isSuccess` | `bool` | Is success |
| `isSubmitting` | `bool` | Is submitting |
| `isRefreshing` | `bool` | Is refreshing |
| `isLoadingMore` | `bool` | Is loading more |
| `hasData` | `bool` | Has data |
| `hasError` | `bool` | Has error |
| `displayMessage` | `String` | Auto message |

## 🎨 Common Patterns

### Pattern 1: Load Data
```dart
// Bloc
on<LoadDataEvent>((event, emit) async {
  await onQuery(emit: emit, action: () => repository.getData());
});

// Cubit
Future<void> loadData() async {
  await onQuery(action: () => repository.getData());
}
```

### Pattern 2: Create/Update/Delete
```dart
// Bloc
on<CreateEvent>((event, emit) async {
  await onMutation(
    emit: emit,
    action: () => repository.create(event.item),
    successMessage: 'Created!',
    onSuccess: (_) => add(LoadDataEvent()),
  );
});

// Cubit
Future<void> create(Item item) async {
  await onMutation(
    action: () => repository.create(item),
    successMessage: 'Created!',
    onSuccess: (_) => loadData(),
  );
}
```

### Pattern 3: Refresh
```dart
// Bloc
on<RefreshEvent>((event, emit) async {
  await onQuery(emit: emit, action: () => repository.getData());
});

// Cubit
Future<void> refresh() async {
  await onQuery(action: () => repository.getData());
}
```

### Pattern 4: Search with Debounce
```dart
// Bloc
on<SearchEvent>((event, emit) async {
  await onQuery(
    emit: emit,
    action: () => repository.search(event.query),
    cancelPrevious: true,  // Cancel old searches
  );
});

// Cubit
Future<void> search(String query) async {
  await onQuery(
    action: () => repository.search(query),
    cancelPrevious: true,
  );
}
```

## 📖 Documentation

- **[BLOC_CUBIT_GUIDE.md](./BLOC_CUBIT_GUIDE.md)** - Tổng hợp tất cả khái niệm
- **[example/bloc_example.dart](./example/bloc_example.dart)** - Ví dụ Bloc
- **[example/cubit_example.dart](./example/cubit_example.dart)** - Ví dụ Cubit

## 🎓 Khi nào dùng gì?

| Tình huống | Recommendation |
|------------|----------------|
| Simple state (counter, toggle) | **Cubit** |
| Complex flows (auth, checkout) | **Bloc** |
| Need event tracking | **Bloc** |
| Quick prototype | **Cubit** |
| Large team | **Bloc** |
| Small team | **Cubit** |

## 💡 Tips

- Sử dụng `onQuery()` cho GET operations
- Sử dụng `onMutation()` cho POST/PUT/DELETE
- Sử dụng `BlocListener` cho side effects
- Sử dụng `BlocBuilder` cho UI rendering
- Sử dụng `BlocConsumer` khi cần cả hai
- Sử dụng `BlocSelector` để optimize rebuilds

---

**Happy Coding! 🎉**
