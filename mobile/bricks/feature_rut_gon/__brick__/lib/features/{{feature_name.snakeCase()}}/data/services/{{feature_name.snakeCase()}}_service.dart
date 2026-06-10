import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../../core/common/constants/api_endpoints.dart';

import '../models/{{feature_name.snakeCase()}}_model.dart';

part '{{feature_name.snakeCase()}}_service.g.dart';

@RestApi()
@LazySingleton()
abstract class {{feature_name.pascalCase()}}Service {
  @factoryMethod
  factory {{feature_name.pascalCase()}}Service(Dio dio) = _{{feature_name.pascalCase()}}Service;

  @GET(ApiEndpoints.{{feature_name.camelCase()}}s)
  Future<List<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}s({@Queries() Map<String, dynamic>? params});

  @GET('${ApiEndpoints.{{feature_name.camelCase()}}s}/{id}')
  Future<{{feature_name.pascalCase()}}Model> get{{feature_name.pascalCase()}}Detail(@Path('id') String id);

  @POST(ApiEndpoints.{{feature_name.camelCase()}}s)
  Future<{{feature_name.pascalCase()}}Model> create{{feature_name.pascalCase()}}(@Body() {{feature_name.pascalCase()}}Model data);

  @PUT('${ApiEndpoints.{{feature_name.camelCase()}}s}/{id}')
  Future<{{feature_name.pascalCase()}}Model> update{{feature_name.pascalCase()}}(
    @Path('id') String id,
    @Body() {{feature_name.pascalCase()}}Model data,
  );

  @DELETE('${ApiEndpoints.{{feature_name.camelCase()}}s}/{id}')
  Future<dynamic> delete{{feature_name.pascalCase()}}(@Path('id') String id);
}
