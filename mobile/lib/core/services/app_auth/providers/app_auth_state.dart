// import 'package:flutter_base/core/base/state/base_status.dart';
// import 'package:flutter_base/features/auth/data/models/auth_model.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'app_auth_state.freezed.dart';

// @freezed
// abstract class AppAuthState with _$AppAuthState {
//   const factory AppAuthState({
//     required AuthStatus status,
//     UserModel? user,
//     String? error,
//     String? message,
//   }) = _AppAuthState;

//   const AppAuthState._();

//   factory AppAuthState.initial() => const AppAuthState(status: AuthStatus.initial);

//   bool get isAuthenticated => status == AuthStatus.authenticated;
//   bool get isUnauthenticated => status == AuthStatus.unauthenticated;
//   bool get isLoading => status == AuthStatus.loading;
//   bool get isExpired => status == AuthStatus.expired;
//   bool get isInitial => status == AuthStatus.initial;
//   bool get hasUser => user != null;
// }
