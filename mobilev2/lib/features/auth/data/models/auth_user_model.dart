import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

/// User trả về từ backend auth (`/auth/login`, `/auth/register`, `/users/me`).
///
/// JSON keys camelCase khớp backend nên KHÔNG cần `@JsonKey`.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String displayName,
    required String role,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? shopId,
    @Default(false) bool isPremium,
    DateTime? premiumUntil,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
