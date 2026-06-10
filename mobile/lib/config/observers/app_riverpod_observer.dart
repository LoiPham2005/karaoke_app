import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod lifecycle observer — chỉ bật ở Dev/Staging.
/// Đăng ký trong ProviderContainer tại main_common.dart.
base class AppRiverpodObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    Logger.debug('▶ created — value: $value', tag: _tag(context));
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    Logger.debug(
      '⟳ updated\n  prev: $previousValue\n  next: $newValue',
      tag: _tag(context),
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Logger.error('failed', error: error, stackTrace: stackTrace, tag: _tag(context));
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    Logger.debug('■ disposed', tag: _tag(context));
  }

  String _tag(ProviderObserverContext context) =>
      'RIVERPOD:${context.provider.name ?? context.provider.runtimeType}';
}
