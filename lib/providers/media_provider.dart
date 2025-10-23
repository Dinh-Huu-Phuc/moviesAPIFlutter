import 'package:flutter/material.dart';
import '../repos/media_repo.dart';
import '../models/media_dto.dart';
// import '../models/paged_media_dto.dart'; // Không cần trực tiếp ở đây

enum MediaTypeFilter { all, video, image }

class MediaProvider extends ChangeNotifier {
  final MediaRepo repo;
  MediaProvider(this.repo);

  bool loading = false;
  String? error;
  List<MediaInfoDTO> items = [];
  bool hasMore = true;

  // ✅ DANH SÁCH MỚI DÀNH RIÊNG CHO POSTER Ở TRANG CHỦ
  List<MediaInfoDTO> homePagePosters = [];

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
    // Chỉ tải thêm nếu không phải tab "Ảnh" (vì API ảnh không phân trang)
    if (!hasMore || loading || _type == MediaTypeFilter.image) return;
    _page++;
    await _load(append: true);
  }

  // ===== HÀM GỌI API CỐT LÕI (ĐÃ CẬP NHẬT) =====
  Future<void> _load({bool append = false}) async {
    if (loading) return;
    loading = true;
    error = null;
    if (!append) {
      // Chỉ notify nếu là refresh (append=false)
      // Khi tải thêm (append=true), indicator ở cuối list đã đủ
      notifyListeners();
    }

    try {
      if (_type == MediaTypeFilter.image) {
        // --- 1. Tải dữ liệu cho tab "Ảnh" ---
        if (append) return; // API ảnh không phân trang
        final res = await repo.listPosters();
        items = res;
        homePagePosters.clear(); // Xóa poster trang chủ khi không ở tab "Tất cả"
        hasMore = false;
      
      } else if (_type == MediaTypeFilter.video) {
        // --- 2. Tải dữ liệu cho tab "Video" (chỉ video, phân trang) ---
        homePagePosters.clear(); // Xóa poster trang chủ
        final res = await repo.listPaged(
          movieId: _movieId,
          type: "video",
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

      } else {
        // --- 3. Tải dữ liệu cho tab "Tất cả" (Ảnh + Video) ---
        
        // Tải media phân trang (video)
        final pagedRes = await repo.listPaged(
          movieId: _movieId,
          type: "all", // "all" ở đây giả định là trả về video/phim
          q: _query,
          pageNumber: _page,
          pageSize: _pageSize,
        );

        if (append) {
          // Nếu là tải thêm, chỉ thêm media phân trang (video) vào `items`
          items.addAll(pagedRes.items);
        } else {
          // Nếu là refresh (trang 1), tải cả ảnh và video
          final posterRes = await repo.listPosters();
          homePagePosters = posterRes; // ✅ Lưu ảnh vào danh sách riêng
          items = pagedRes.items; // ✅ Lưu video vào danh sách `items`
        }
        
        // Phân trang chỉ dựa trên media (video)
        hasMore = _page < pagedRes.totalPages;
      }
    } catch (e) {
      error = e.toString();
      if (_page > 1 && append) _page--; // Nếu lỗi khi tải thêm, quay lại trang trước
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ===== CÁC HÀM TIỆN ÍCH (HELPERS) ĐƯỢC GIỮ LẠI =====

  String urlOf(MediaInfoDTO m) => repo.resolveUrl(m);

  String posterOf(MediaInfoDTO m) {
    final thumbUrl = repo.resolveThumb(m);
    if (thumbUrl != null && thumbUrl.isNotEmpty) {
      return thumbUrl;
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

