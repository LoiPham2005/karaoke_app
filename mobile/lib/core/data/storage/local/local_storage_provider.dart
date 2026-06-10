import 'package:flutter_base/core/base/di/injection.dart';
import 'package:flutter_base/core/data/storage/local/local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_storage_provider.g.dart';

@riverpod
LocalStorageService localStorageService(Ref ref) {
  return getIt<LocalStorageService>();
}
