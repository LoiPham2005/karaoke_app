// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/di/global_providers.dart
//
// Global ProviderContainer — truy cập Riverpod provider từ ngoài widget tree.
//
// Dùng cho:
//   - AppRouter redirect (kiểm tra auth)
//   - DioClient interceptor (refresh token, logout on 401)
//   - Push notification handler
//   - Background task / isolate
//
// KHÔNG dùng trong Widget — dùng WidgetRef (ref.read/watch) trong widget.
//
// Setup (đã tích hợp sẵn trong App):
//   final container = ProviderContainer(observers: [...]);
//   globalContainer = container;
//   runApp(UncontrolledProviderScope(container: container, child: MyApp()));
//
// Truy cập:
//   globalContainer.read(authProvider);
//   globalContainer.read(authProvider.notifier).logout();
// ════════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global [ProviderContainer] — initialized in [App] before [runApp].
///
/// Chỉ dùng ngoài widget tree. Trong widget luôn dùng [WidgetRef].
late final ProviderContainer globalContainer;
