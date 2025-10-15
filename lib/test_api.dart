import 'package:dio/dio.dart';

Future<void> testFetchAll() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5099', // đổi đúng port theo swagger
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  try {
    final res = await dio.get('/api/Movies/get-all-movies', queryParameters: {
      'filterOn': null,
      'filterQuery': null,
      'sortBy': 'title',
      'isAscending': true,
      'pageNumber': 1,
      'pageSize': 10,
    });

    print('Status: ${res.statusCode}');
    print('Data: ${res.data}');
  } catch (e) {
    print('❌ Lỗi khi gọi API: $e');
  }
}
