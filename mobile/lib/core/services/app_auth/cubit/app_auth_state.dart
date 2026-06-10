// // ════════════════════════════════════════════════════════════════
// // 📁 lib/core/services/app_auth/app_auth_state.dart
// // ════════════════════════════════════════════════════════════════
// import 'package:equatable/equatable.dart';
// import 'package:flutter_base/features/auth/data/models/auth_model.dart';

// import '../../../base/state/base_status.dart';

// /// 🔐 Global Authentication State
// class AppAuthState extends Equatable {
//   final AuthStatus status;
//   final UserModel? user;
//   final String? error;
//   final String? message;

//   const AppAuthState({
//     required this.status,
//     this.user,
//     this.error,
//     this.message,
//   });

//   // ════════════════════════════════════════════════════════════
//   // Factories
//   // ════════════════════════════════════════════════════════════

//   factory AppAuthState.initial() =>
//       const AppAuthState(status: AuthStatus.initial);

//   factory AppAuthState.unauthenticated({String? error}) =>
//       AppAuthState(status: AuthStatus.unauthenticated, error: error);

//   factory AppAuthState.loading() =>
//       const AppAuthState(status: AuthStatus.loading);

//   factory AppAuthState.authenticated(UserModel user, {String? message}) =>
//       AppAuthState(
//         status: AuthStatus.authenticated,
//         user: user,
//         message: message,
//       );

//   factory AppAuthState.expired({String? message}) => AppAuthState(
//     status: AuthStatus.expired,
//     message: message ?? 'Phiên đăng nhập hết hạn',
//   );

//   factory AppAuthState.unauthorized({String? error}) => AppAuthState(
//     status: AuthStatus.unauthorized,
//     error: error ?? 'Bạn không có quyền truy cập',
//   );

//   // ════════════════════════════════════════════════════════════
//   // Getters
//   // ════════════════════════════════════════════════════════════

//   bool get isAuthenticated => status == AuthStatus.authenticated;
//   bool get isUnauthenticated => status == AuthStatus.unauthenticated;
//   bool get isLoading => status == AuthStatus.loading;
//   bool get isExpired => status == AuthStatus.expired;
//   bool get isInitial => status == AuthStatus.initial;

//   bool get hasUser => user != null;

//   // ════════════════════════════════════════════════════════════
//   // Utility
//   // ════════════════════════════════════════════════════════════

//   AppAuthState copyWith({
//     AuthStatus? status,
//     UserModel? user,
//     String? error,
//     String? message,
//   }) {
//     return AppAuthState(
//       status: status ?? this.status,
//       user: user ?? this.user,
//       error: error ?? this.error,
//       message: message ?? this.message,
//     );
//   }

//   @override
//   List<Object?> get props => [status, user, error, message];

//   @override
//   String toString() => 'AppAuthState(status: $status, user: ${user?.email})';
// }
