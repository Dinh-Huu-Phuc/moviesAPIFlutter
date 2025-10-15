import 'package:dio/dio.dart';
import 'env.dart';

class DioClient {
  final Dio dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  String? _jwt;

  DioClient() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      if (_jwt?.isNotEmpty == true) {
        o.headers['Authorization'] = 'Bearer $_jwt';
      }
      h.next(o);
    }));
  }

  void setToken(String? token) => _jwt = token;
}
