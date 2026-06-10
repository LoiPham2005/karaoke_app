import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../core/data/network/api_paginated_data.dart';
import '../../../../../core/data/network/api_response.dart';
import '../models/{{name.snakeCase()}}_model.dart';

part '{{name.snakeCase()}}_service.g.dart';

@RestApi()
@LazySingleton()
abstract class {{name.pascalCase()}}Service {
  @factoryMethod
  factory {{name.pascalCase()}}Service(Dio dio) = _{{name.pascalCase()}}Service;

  @GET('/api/{{name.paramCase()}}s')
  Future<ApiResponse<ApiPaginatedData<{{name.pascalCase()}}Model>>> getList({
    @Queries() Map<String, dynamic>? params,
  });

  @GET('/api/{{name.paramCase()}}s/{id}')
  Future<ApiResponse<{{name.pascalCase()}}Model>> getDetail(@Path('id') int id);

  @POST('/api/{{name.paramCase()}}s')
  Future<ApiResponse<{{name.pascalCase()}}Model>> create(@Body() Map<String, dynamic> body);

  @PUT('/api/{{name.paramCase()}}s/{id}')
  Future<ApiResponse<{{name.pascalCase()}}Model>> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/{{name.paramCase()}}s/{id}')
  Future<void> delete(@Path('id') int id);
}
