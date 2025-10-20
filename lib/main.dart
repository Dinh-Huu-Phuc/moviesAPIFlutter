import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'services/movies_api.dart';
import 'repos/movie_repo.dart';
import 'providers/movie_provider.dart';
import 'repos/media_repo.dart';
import 'providers/media_provider.dart';
import 'providers/auth_service.dart';
import 'Screen/movie.dart'; // ✅ Thêm import cho trang MovieDisplay

void main() {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5099', // Hoặc IP của máy bạn nếu dùng máy thật
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  final moviesApi = MoviesApi(dio, baseUrl: dio.options.baseUrl);
  final movieRepo = MovieRepo(moviesApi);
  final mediaRepo = MediaRepo(moviesApi, dio, baseUrl: dio.options.baseUrl);

  runApp(
    // Giữ lại MultiProvider để các trang khác vẫn có thể truy cập
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider(movieRepo)),
        ChangeNotifierProvider(create: (_) => MediaProvider(mediaRepo)),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phim Lậu',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      // ✅ THAY ĐỔI TRANG CHỦ TẠI ĐÂY
      home: const MovieDisplay(),
    );
  }
}

