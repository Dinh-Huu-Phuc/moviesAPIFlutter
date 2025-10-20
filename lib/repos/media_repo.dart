import 'dart:convert';
import 'package:dio/dio.dart';

import '../config/api_base.dart';
import '../services/movies_api.dart';
import '../models/media_dto.dart';
import '../models/paged_media_dto.dart';

class MediaRepo {
  final MoviesApi api;
  final Dio dio;

  /// Có thể truyền khác đi nếu cần, mặc định lấy từ ApiBase.base
  final String baseUrl;

  MediaRepo(this.api, this.dio, {String? baseUrl})
      : baseUrl = baseUrl ?? ApiBase.base;

  // ==================================================
  // HÀM CŨ (GIỮ NGUYÊN)
  // ==================================================
  Future<List<MediaInfoDTO>> list() => api.getAllMedia();

  // ==================================================
  // ✅ PHÂN TRANG: map đúng tham số pageNumber, pageSize
  // ==================================================
  Future<PagedMediaResponseDTO> listPaged({
    int pageNumber = 1,
    int pageSize = 24,
    int? movieId,
    String type = 'all', // 'all' | 'video' | 'image'
    String? q,
  }) async {
    final uri = ApiBase.build('/api/Movie/GetMediaPaged', {
      'pageNumber': '$pageNumber',
      'pageSize': '$pageSize',
      'type': type,
      if (movieId != null) 'movieId': '$movieId',
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    });

    final resp = await dio.get(uri.toString());
    return PagedMediaResponseDTO.fromJson(resp.data);
  }

  // ==================================================
  // ✅ Chuẩn hoá URL (khi BE trả localhost/Images, app đang chạy device)
  // ==================================================
  String _normalizeUrl(String raw) {
    if (raw.isEmpty) return raw;

    // chuẩn hoá /Images -> /uploads
    var u = raw.replaceAll('/Images/', '/uploads/');

    // thay các localhost bằng baseUrl hiện tại
    final targets = <String>[
      'https://localhost:7138',
      'http://localhost:7138',
      'http://localhost:5099',
      'http://0.0.0.0:5099',
    ];
    for (final t in targets) {
      if (u.startsWith(t)) {
        // ghép path phía sau vào baseUrl hiện tại
        final path = u.substring(t.length);
        final b = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
        u = '$b$path';
        break;
      }
    }

    try {
      return Uri.parse(u).toString();
    } catch (_) {
      return u;
    }
  }

  // ==================================================
  // ✅ Trả URL tuyệt đối cho video/ảnh
  // ==================================================
  String resolveUrl(MediaInfoDTO m) {
    // Ưu tiên server trả sẵn fileUrl
    if ((m.fileUrl?.isNotEmpty ?? false)) {
      return _normalizeUrl(m.fileUrl!);
    }

    // Fallback: có fileName thì build từ /uploads
    if (m.fileName.isNotEmpty) {
      return ApiBase.uploads(m.fileName);
    }

    return '';
  }

  // ==================================================
  // ✅ Trả URL thumbnail (nếu có)
  // ==================================================
  String? resolveThumb(MediaInfoDTO m) {
    if ((m.thumbnailUrl?.isNotEmpty ?? false)) {
      return _normalizeUrl(m.thumbnailUrl!);
    }
    if ((m.thumbnailFileName?.isNotEmpty ?? false)) {
      return ApiBase.uploads(m.thumbnailFileName!);
    }
    return null;
  }
}
