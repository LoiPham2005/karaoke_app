import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'injection.dart';

part 'dio_provider.g.dart';

/// Provider để lấy Dio từ GetIt sang Riverpod
@riverpod
Dio dio(Ref ref) {
  return getIt<Dio>();
}
