// 📁 lib/core/services/iap/models/iap_models.dart

/// Kết quả sau mỗi lần purchase / restore.
class AppPurchaseResult {
  const AppPurchaseResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.message,
  });

  final bool isSuccess;
  final bool isCancelled;
  final String? message;

  factory AppPurchaseResult.success([String? msg]) =>
      AppPurchaseResult._(isSuccess: true, isCancelled: false, message: msg);

  factory AppPurchaseResult.error(String msg) =>
      AppPurchaseResult._(isSuccess: false, isCancelled: false, message: msg);

  factory AppPurchaseResult.cancelled() => const AppPurchaseResult._(
    isSuccess: false,
    isCancelled: true,
    message: 'Purchase cancelled',
  );

  bool get isError => !isSuccess && !isCancelled;

  @override
  String toString() =>
      'AppPurchaseResult('
      'success=$isSuccess, cancelled=$isCancelled, msg=$message)';
}
