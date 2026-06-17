import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/features/auth/data/models/auth_user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Payload `data` của `/auth/login`, `/auth/register`, `/auth/refresh`.
@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
