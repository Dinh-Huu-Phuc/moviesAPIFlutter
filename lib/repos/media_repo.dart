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
  // PHÂN TRANG (GIỮ NGUYÊN)
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
  // ✅ HÀM MỚI ĐỂ LẤY DỮ LIỆU POSTER (ẢNH)
  // ==================================================
  Future<List<MediaInfoDTO>> listPosters() async {
    final uri = ApiBase.build('/api/Poster');
    
    final resp = await dio.get(uri.toString());

    if (resp.data is List) {
      final List<dynamic> posterList = resp.data;
      
      // Map dữ liệu PosterDto (từ API) sang MediaInfoDTO (dùng chung trong app)
      return posterList.map((json) {
        return MediaInfoDTO(
          id: json['id'] ?? 0,
          // Với ảnh, fileUrl và thumbnailUrl là một
          fileUrl: _normalizeUrl(json['fileUrl'] ?? ''),
          thumbnailUrl: _normalizeUrl(json['fileUrl'] ?? ''),
          
          fileName: json['fileName'] ?? '',
          fileExtension: json['fileExtension'] ?? '.jpg',
          fileSizeInBytes: json['fileSizeInBytes'] ?? 0,
          fileDescription: json['fileDescription'],
          
          // Dùng FileDescription hoặc FileName làm Title
          title: json['fileDescription'] ?? json['fileName'],
          intro: json['fileDescription'],
        );
      }).toList();
    } else {
      // Nếu API không trả về một danh sách, ném ra lỗi
      throw Exception('API /api/Poster không trả về dữ liệu mong muốn.');
    }
  }


  // ==================================================
  // CÁC HÀM HELPER (GIỮ NGUYÊN)
  // ==================================================
  
  String _normalizeUrl(String raw) {
    if (raw.isEmpty) return raw;
    var u = raw.replaceAll('/Images/', '/uploads/');
    final targets = <String>[
      'https://localhost:7138',
      'http://localhost:7138',
      'http://localhost:5099',
      'http://0.0.0.0:5099',
    ];
    for (final t in targets) {
      if (u.startsWith(t)) {
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

  String resolveUrl(MediaInfoDTO m) {
    if ((m.fileUrl?.isNotEmpty ?? false)) {
      return _normalizeUrl(m.fileUrl!);
    }
    if (m.fileName.isNotEmpty) {
      return ApiBase.uploads(m.fileName);
    }
    return '';
  }

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
