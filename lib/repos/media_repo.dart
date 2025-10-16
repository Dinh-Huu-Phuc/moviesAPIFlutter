import 'dart:convert';
import 'package:dio/dio.dart';

import '../services/movies_api.dart';
import '../models/media_dto.dart';
import '../models/paged_media_dto.dart';

const String _hostHttp = 'http://10.0.2.2:5099';

class MediaRepo {
  final MoviesApi api;
  final Dio dio;
  final String baseUrl;

  MediaRepo(this.api, this.dio, {required this.baseUrl});

  // ==================================================
  // HÀM CŨ (GIỮ NGUYÊN)
  // ==================================================
  Future<List<MediaInfoDTO>> list() => api.getAllMedia();

  // ==================================================
  // ✅ HÀM ĐƯỢC CẬP NHẬT
  // ==================================================
  Future<PagedMediaResponseDTO> listPaged({
    int pageNumber = 1,      // Đổi tên tham số
    int pageSize = 24,       // Đổi tên tham số
    int? movieId,
    String type = 'all',
    String? q,
  }) async {
    final url = '$baseUrl/api/Movie/GetMediaPaged';
    final resp = await dio.get(url, queryParameters: {
      'pageNumber': pageNumber, // Giờ đây tên khớp nhau
      'pageSize': pageSize,   // Giờ đây tên khớp nhau
      if (movieId != null) 'movieId': movieId,
      'type': type,
      if (q != null && q.isNotEmpty) 'q': q,
    });
    return PagedMediaResponseDTO.fromJson(resp.data);
  }

  // ==================================================
  // HÀM CŨ (GIỮ NGUYÊN)
  // ==================================================
  String resolveUrl(MediaInfoDTO m) {
    var raw = (m.fileUrl?.isNotEmpty ?? false) ? m.fileUrl! : '';

    if (raw.isEmpty && (m.fileName.isNotEmpty)) {
      raw = '$_hostHttp/uploads/${m.fileName}';
    }

    raw = raw
        .replaceAll('https://localhost:7138', _hostHttp)
        .replaceAll('http://localhost:7138', _hostHttp)
        .replaceAll('http://localhost:5099', _hostHttp)
        .replaceAll('/Images/', '/uploads/');

    try {
      return Uri.parse(raw).toString();
    } catch (_) {
      return raw;
    }
  }
}