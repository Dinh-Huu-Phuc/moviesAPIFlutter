import 'package:dio/dio.dart';

/// Tạo 1 Dio dùng chung + gắn JWT nếu có
class ApiClient {
  final Dio dio;
  String? _jwt;

  ApiClient({required String baseUrl})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Accept': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) {
        if (_jwt?.isNotEmpty == true) {
          o.headers['Authorization'] = 'Bearer $_jwt';
        }
        h.next(o);
      },
    ));
  }

  void setToken(String? token) => _jwt = token;
}
