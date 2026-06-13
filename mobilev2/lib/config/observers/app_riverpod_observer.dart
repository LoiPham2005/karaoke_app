import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karaoke/core/services/utils/logger.dart';

/// Riverpod 3.x ProviderObserver — log provider lifecycle để debug.
final class AppRiverpodObserver extends ProviderObserver {
  const AppRiverpodObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    Logger.riverpodAdd(context.provider.name ?? context.provider.runtimeType.toString());
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    Logger.riverpodUpdate(
      context.provider.name ?? context.provider.runtimeType.toString(),
      previousValue,
      newValue,
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Logger.riverpodError(
      context.provider.name ?? context.provider.runtimeType.toString(),
      error,
      stackTrace,
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    Logger.riverpodDispose(context.provider.name ?? context.provider.runtimeType.toString());
  }
}
