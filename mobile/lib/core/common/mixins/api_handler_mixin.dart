// ════════════════════════════════════════════════════════════════
// 📁 lib/core/mixins/api_handler_mixin.dart
// ════════════════════════════════════════════════════════════════

import '../../base/errors/error_handler.dart';
import '../../base/errors/result.dart';
import '../../data/network/api_response.dart';
import '../../base/errors/failures.dart';

/// 🎯 Mixin giúp thực thi các lệnh gọi API một cách an toàn.
/// Tự động xử lý try-catch, bắt lỗi qua ErrorHandler và trả về [Result].
mixin ApiHandlerMixin {
  /// Thực thi một request API và trả về Result<T>
  Future<Result<T>> safeCall<T>(Future<T> Function() action) async {
    try {
      final response = await action();
      return ResultSuccess(response);
    } catch (e, stackTrace) {
      return ResultFailure(ErrorHandler.toFailure(e, stackTrace));
    }
  }

  /// ✅ NEW: Bóc gói ApiResponse<T> tự động để lấy T
  Future<Result<T>> safeCallUnwrap<T>(
    Future<ApiResponse<T>> Function() action,
  ) async {
    try {
      final response = await action();
      if (response.isSuccess && response.data != null) {
        return ResultSuccess(response.data!);
      }
      return ResultFailure(ServerFailure(
        message: response.message ?? 'Đã có lỗi xảy ra',
        statusCode: response.statusCode,
      ));
    } catch (e, stackTrace) {
      return ResultFailure(ErrorHandler.toFailure(e, stackTrace));
    }
  }

  /// Thực thi một request API trả về thành công/thất bại (bool)
  Future<Result<bool>> safeCallBool(Future<dynamic> Function() action) async {
    try {
      await action();
      return const ResultSuccess(true);
    } catch (e, stackTrace) {
      return ResultFailure(ErrorHandler.toFailure(e, stackTrace));
    }
  }
}
