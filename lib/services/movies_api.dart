// lib/services/movies_api.dart

import 'package:dio/dio.dart';
import 'package:movie_api_flutter/models/media_dto.dart';
import 'package:retrofit/retrofit.dart';
import '../models/movie_dto.dart'; // Đảm bảo đường dẫn này đúng
import '../models/media_dto.dart';

// Dòng này liên kết với file do máy tạo ra
part 'movies_api.g.dart';

@RestApi()
abstract class MoviesApi {
  factory MoviesApi(Dio dio, {String baseUrl}) = _MoviesApi;

  @GET("/api/Movies/get-all-movies")
  Future<List<MovieWithCastAndStudioDTO>> getAllMovies(
    @Query("filterOn") String? filterOn,
    @Query("filterQuery") String? filterQuery,
    @Query("sortBy") String? sortBy,
    @Query("isAscending") bool isAscending,
    @Query("pageNumber") int pageNumber,
    @Query("pageSize") int pageSize,
  );

  @GET("/api/Movies/get-movie-by-id/{id}")
  Future<MovieWithCastAndStudioDTO> getMovieById(@Path("id") int id);

  @POST("/api/Movies/add-movie")
  Future<void> addMovie(@Body() AddMovieRequestDTO body);

  @PUT("/api/Movies/update-movie-by-id/{id}")
  Future<void> updateMovie(@Path("id") int id, @Body() AddMovieRequestDTO body);

  @DELETE("/api/Movies/delete-movie-by-id/{id}")
  Future<void> deleteMovie(@Path("id") int id);

  // ✅ THÊM CÁC HÀM MỚI VÀO ĐÂY
  /// Lấy danh sách file đã upload (ảnh/video)
  @GET("/api/Movie/GetAllImages")
  Future<List<MediaInfoDTO>> getAllMedia();

  /// Tải file (nếu muốn tải về), hiện tại ta phát trực tiếp qua URL nên chưa dùng.
  @GET("/api/Movie/Download")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> downloadFile(@Query("id") int id);
}