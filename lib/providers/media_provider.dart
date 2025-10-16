import 'package:flutter/material.dart';
// import 'dart.async';
// import 'package.flutter/foundation.dart';
import '../repos/media_repo.dart';
import '../models/media_dto.dart';
import '../models/paged_media_dto.dart';

enum MediaTypeFilter { all, video, image }

class MediaProvider extends ChangeNotifier {
  final MediaRepo repo;
  MediaProvider(this.repo);

  bool loading = false;
  String? error;
  List<MediaInfoDTO> items = [];
  bool hasMore = true;

  // --- Trạng thái bộ lọc (private) ---
  MediaTypeFilter _type = MediaTypeFilter.all;
  int? _movieId;
  String _query = "";
  int _page = 1;
  final int _pageSize = 24;

  // ===== CÁC HÀM SETTER CÔNG KHAI ĐỂ THAY ĐỔI BỘ LỌC =====
  void setType(MediaTypeFilter t) {
    if (_type == t) return;
    _type = t;
    refresh(); // Tự động tải lại dữ liệu khi đổi bộ lọc
  }

  void setMovie(int? id) {
    if (_movieId == id) return;
    _movieId = id;
    refresh();
  }

  // ✅ CẬP NHẬT LẠI HÀM NÀY
  void setQuery(String q) {
    final normalized = q.trim();
    if (_query == normalized) return;
    _query = normalized; // rỗng = không lọc
    refresh();
  }

  // ===== CÁC HÀM ĐIỀU KHIỂN LUỒNG DỮ LIỆU =====
  Future<void> refresh() async {
    _page = 1;
    hasMore = true;
    // Không xóa `items` ngay để UI không bị giật, `_load` sẽ thay thế nó
    await _load(append: false);
  }

  Future<void> fetchMore() async {
    if (!hasMore || loading) return;
    _page++;
    await _load(append: true);
  }

  // ===== HÀM GỌI API CỐT LÕI =====
  Future<void> _load({bool append = false}) async {
    if (loading) return;
    loading = true;
    error = null;
    if (!append) {
      notifyListeners();
    }

    try {
      final typeStr = switch (_type) {
        MediaTypeFilter.video => "video",
        MediaTypeFilter.image => "image",
        _ => "all",
      };

      final res = await repo.listPaged(
        movieId: _movieId,
        type: typeStr,
        q: _query,
        pageNumber: _page,
        pageSize: _pageSize,
      );

      if (append) {
        items.addAll(res.items);
      } else {
        items = res.items;
      }

      hasMore = _page < res.totalPages;
    } catch (e) {
      error = e.toString();
      if (_page > 1) _page--;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ===== CÁC HÀM TIỆN ÍCH (HELPERS) ĐƯỢC GIỮ LẠI =====

  String urlOf(MediaInfoDTO m) => repo.resolveUrl(m);

  String posterOf(MediaInfoDTO m) {
    if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty) {
      final tempDtoForThumbnail = MediaInfoDTO(
          id: m.id,
          fileName: m.fileName,
          fileExtension: m.fileExtension,
          fileSizeInBytes: m.fileSizeInBytes,
          fileDescription: m.fileDescription,
          fileUrl: m.thumbnailUrl);
      return repo.resolveUrl(tempDtoForThumbnail);
    }
    return repo.resolveUrl(m);
  }

  bool isVideo(MediaInfoDTO m) {
    final e = (m.fileExtension).toLowerCase();
    return e == '.mp4' || e == '.mov' || e == '.m4v' || e == '.webm';
  }

  String displayName(MediaInfoDTO m) =>
      (m.fileDescription?.isNotEmpty ?? false)
          ? m.fileDescription!
          : ((m.title?.isNotEmpty ?? false) ? m.title! : m.fileName);
}