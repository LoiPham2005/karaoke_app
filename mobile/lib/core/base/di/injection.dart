import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/core/data/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String? environment}) async =>
    getIt.init(environment: environment);

/// 🧹 Reset toàn bộ dependencies (Dọn dẹp bộ nhớ)
Future<void> resetDependencies() async {
  await getIt.reset(dispose: true);
}

/// 🔄 Reset và khởi tạo lại (Dùng cho Logout/Switch Account)
Future<void> resetAndReinitDependencies() async {
  await resetDependencies();
  await configureDependencies(environment: FlavorConfig.flavor.name);
}

@module
abstract class RegisterModule {
  /// SharedPreferences: @preResolve để đảm bảo nó có sẵn trước các service khác
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  /// 🔒 FlutterSecureStorage mạnh nhất:
  /// - resetOnError: Tự dọn dẹp nếu Keystore bị lỗi (rất hay gặp trên Android)
  /// - first_unlock_this_device: Bảo mật cấp cao nhất, không đồng bộ iCloud
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    // ignore: deprecated_member_use
    aOptions: AndroidOptions(encryptedSharedPreferences: true, resetOnError: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  /// 🌐 InternetConnection: Cấu hình DNS tin cậy (tránh bị chặn ở một số vùng)
  @lazySingleton
  InternetConnection get internetConnection => InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 10),
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse('https://1.1.1.1')),
      InternetCheckOption(uri: Uri.parse('https://8.8.8.8')),
    ],
  );

  /// 🛠 Dio: Injection qua parameter là cách sạch nhất (Best Practice)
  @lazySingleton
  Dio dio(DioClient dioClient) => dioClient.dio;

  @lazySingleton
  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;
}
