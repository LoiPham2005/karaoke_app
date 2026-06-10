// 📁 lib/core/data/network/graphql_module.dart
//
// GraphQL client setup — register `GraphQLClient` qua Injectable
// để các Service inject via constructor.
//
// Endpoint mặc định: FlavorConfig.apiBaseUrl + '/graphql'.
// Để TEST với public API thay vì backend nội bộ, sửa `_endpointUrl`.
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

@module
abstract class GraphQLModule {
  /// 🌐 Public test endpoint — Rick & Morty GraphQL (KHÔNG auth).
  /// Đổi sang false khi backend nội bộ đã có /graphql.
  static const _useDemoEndpoint = true;

  static const _demoEndpoint = 'https://rickandmortyapi.com/graphql';

  static String get _endpointUrl => _useDemoEndpoint
      ? _demoEndpoint
      : '${FlavorConfig.apiBaseUrl}/graphql';

  @LazySingleton()
  GraphQLClient graphQLClient() {
    Logger.info('🛰  GraphQL endpoint: $_endpointUrl', tag: 'GRAPHQL');

    final httpLink = HttpLink(_endpointUrl);

    // Auth interceptor — gắn Bearer token khi cần.
    // Hiện trả null → request không có Authorization header.
    final authLink = AuthLink(
      getToken: () async {
        // final token = await getIt<LocalStorageService>().getAccessToken();
        // return token != null ? 'Bearer $token' : null;
        return null;
      },
    );

    return GraphQLClient(
      link: authLink.concat(httpLink),
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );
  }
}
