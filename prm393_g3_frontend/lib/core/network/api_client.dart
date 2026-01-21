import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> get(String path) => _dio.get<dynamic>(path);
  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _dio.post<dynamic>(path, data: data);
}
