import 'dart:convert';
import 'package:dio/dio.dart';

import '../services/movies_api.dart';
import '../models/media_dto.dart';
import '../models/paged_media_dto.dart'; // <-- Import mới

// Hằng số host giữ nguyên
const String _hostHttp = 'http://10.0.2.2:5099';

class MediaRepo {
  final MoviesApi api;
  final Dio dio; // <-- Thêm Dio dependency
  final String baseUrl;

  // Cập nhật constructor để nhận cả MoviesApi và Dio
  MediaRepo(this.api, this.dio, {required this.baseUrl});

  // ==================================================
  // HÀM CŨ (GIỮ NGUYÊN)
  // ==================================================
  Future<List<MediaInfoDTO>> list() => api.getAllMedia();

  // ==================================================
  // HÀM MỚI (BỔ SUNG)
  // ==================================================
  Future<PagedMediaResponseDTO> listPaged({
    int page = 1,
    int size = 24,
    int? movieId,
    String type = 'all', // all | video | image
    String? q,
  }) async {
    // Gọi thẳng API bằng Dio vì Retrofit chưa định nghĩa hàm này
    final url = '$baseUrl/api/Movie/GetMediaPaged';
    final resp = await dio.get(url, queryParameters: {
      'pageNumber': page,
      'pageSize': size,
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
    // 1) Ưu tiên API đã trả fileUrl
    var raw = (m.fileUrl?.isNotEmpty ?? false) ? m.fileUrl! : '';

    // 2) Fallback: tự dựng URL từ fileName nếu fileUrl trống
    if (raw.isEmpty && (m.fileName.isNotEmpty)) {
      raw = '$_hostHttp/uploads/${m.fileName}';
    }

    // 3) Chuẩn hoá các URL cũ/trái chuẩn để tương thích ngược
    raw = raw
        .replaceAll('https://localhost:7138', _hostHttp)
        .replaceAll('http://localhost:7138', _hostHttp)
        .replaceAll('http://localhost:5099', _hostHttp)
        .replaceAll('/Images/', '/uploads/');

    // 4) Encode URL để xử lý các ký tự đặc biệt
    try {
      return Uri.parse(raw).toString();
    } catch (_) {
      return raw;
    }
  }
}