// // ════════════════════════════════════════════════════════════════
// // 📁 lib/core/services/app_auth/app_auth_cubit.dart
// // ════════════════════════════════════════════════════════════════
// import 'dart:async';

// import 'package:flutter_base/core/services/app_auth/app_auth_service.dart';
// import 'package:flutter_base/core/services/app_auth/cubit/app_auth_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';

// import '../../../../features/auth/data/models/auth_model.dart';
// import '../../../base/state/base_status.dart';

// /// 🌍 Global App Auth Cubit - Manages the authenticated state of the entire app
// @LazySingleton()
// class AppAuthCubit extends Cubit<AppAuthState> {
//   final AppAuthService _authService;
//   StreamSubscription? _authStreamSubscription;

//   AppAuthCubit(this._authService) : super(AppAuthState.initial()) {
//     _listenToAuthChanges();
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // Initialization
//   // ═══════════════════════════════════════════════════════════════

//   /// Lắng nghe thay đổi trạng thái từ AppAuthService
//   void _listenToAuthChanges() {
//     _authStreamSubscription = _authService.authStateStream.listen((status) {
//       _handleStatusChange(status);
//     });
//   }

//   /// Khởi tạo trạng thái ban đầu của App (gọi lúc Splash/Init)
//   Future<void> checkAuthStatus() async {
//     emit(AppAuthState.loading());

//     final status = await _authService.checkInitialStatus();
//     _handleStatusChange(status);
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // Actions
//   // ═══════════════════════════════════════════════════════════════

//   /// Cập nhật trạng thái sau khi Login thành công
//   Future<void> loginSuccess(AuthResponseModel response) async {
//     await _authService.saveLoginData(response);
//     // AppAuthService sẽ tự emit AuthStatus.authenticated, _listenToAuthChanges sẽ bắt được
//   }

//   /// Thực hiện Logout
//   Future<void> logout() async {
//     await _authService.logout();
//   }

//   /// Cập nhật thông tin user (ví dụ sau khi sửa profile)
//   void updateUser(UserModel user) {
//     if (state.isAuthenticated) {
//       emit(state.copyWith(user: user));
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // Private Logic
//   // ═══════════════════════════════════════════════════════════════

//   void _handleStatusChange(AuthStatus status) {
//     switch (status) {
//       case AuthStatus.authenticated:
//         final user = _authService.currentUser;
//         if (user != null) {
//           emit(AppAuthState.authenticated(user));
//         } else {
//           emit(AppAuthState.unauthenticated());
//         }
//         break;
//       case AuthStatus.unauthenticated:
//         emit(AppAuthState.unauthenticated());
//         break;
//       case AuthStatus.expired:
//         emit(AppAuthState.expired());
//         break;
//       case AuthStatus.unauthorized:
//         emit(AppAuthState.unauthorized());
//         break;
//       case AuthStatus.loading:
//         emit(AppAuthState.loading());
//         break;
//       case AuthStatus.initial:
//         emit(AppAuthState.initial());
//         break;
//     }
//   }

//   @override
//   Future<void> close() {
//     _authStreamSubscription?.cancel();
//     return super.close();
//   }
// }
