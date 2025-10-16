// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'services/movies_api.dart';
import 'repos/movie_repo.dart';
import 'providers/movie_provider.dart';
import 'pages/movie_list_page.dart';

// Import các file cho Media
import 'repos/media_repo.dart';
import 'providers/media_provider.dart';

void main() {
  // Cấu hình Dio, giữ nguyên
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5099',
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // Khởi tạo các API và Repo
  final moviesApi = MoviesApi(dio, baseUrl: dio.options.baseUrl);
  final movieRepo = MovieRepo(moviesApi);

  // ✅ SỬA LẠI DÒNG NÀY ĐỂ TRUYỀN 'dio' VÀO
  final mediaRepo = MediaRepo(moviesApi, dio, baseUrl: dio.options.baseUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider(movieRepo)),
        ChangeNotifierProvider(create: (_) => MediaProvider(mediaRepo)),
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
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      home: const MovieListPage(),
    );
  }
}