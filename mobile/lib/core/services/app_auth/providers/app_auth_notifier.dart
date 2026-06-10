// import 'dart:async';

// import 'package:flutter_base/core/base/di/injection.dart';
// import 'package:flutter_base/core/base/state/base_status.dart';
// import 'package:flutter_base/core/services/app_auth/app_auth_service.dart';
// import 'package:flutter_base/features/auth/data/models/auth_model.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import 'app_auth_state.dart';

// part 'app_auth_notifier.g.dart';

// @Riverpod(keepAlive: true)
// class AppAuth extends _$AppAuth {
//   StreamSubscription? _subscription;

//   @override
//   Future<AppAuthState> build() async {
//     final service = getIt<AppAuthService>();

//     await _subscription?.cancel();
//     _subscription = service.authStateStream.listen((status) {
//       state = AsyncData(_mapStatusToState(service, status));
//     });

//     ref.onDispose(() => _subscription?.cancel());

//     final status = await service.checkInitialStatus();
//     return _mapStatusToState(service, status);
//   }

//   Future<void> loginSuccess(AuthResponseModel response) async {
//     final service = getIt<AppAuthService>();
//     await service.saveLoginData(response);
//     // service tự emit qua authStateStream → _subscription sẽ cập nhật state
//   }

//   Future<void> logout() async {
//     await getIt<AppAuthService>().logout();
//   }

//   void updateUser(UserModel user) {
//     final data = state.asData?.value;
//     if (data?.isAuthenticated == true) {
//       state = AsyncData(data!.copyWith(user: user));
//     }
//   }

//   AppAuthState _mapStatusToState(AppAuthService service, AuthStatus status) {
//     return AppAuthState(
//       status: status,
//       user: status == AuthStatus.authenticated ? service.currentUser : null,
//     );
//   }
// }
