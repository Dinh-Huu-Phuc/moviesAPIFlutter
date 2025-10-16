import 'package:flutter/foundation.dart';
import '../repos/media_repo.dart';
import '../models/media_dto.dart';
import '../models/paged_media_dto.dart';

// Enum để lọc media theo loại
enum MediaTypeFilter { all, video, image }

// Extension để chuyển enum thành param string cho API
extension _ToParam on MediaTypeFilter {
  String get param {
    switch (this) {
      case MediaTypeFilter.video:
        return 'video';
      case MediaTypeFilter.image:
        return 'image';
      case MediaTypeFilter.all:
      default:
        return 'all';
    }
  }
}

class MediaProvider extends ChangeNotifier {
  final MediaRepo repo;
  MediaProvider(this.repo);

  bool loading = false;
  String? error;

  // Trạng thái cho việc phân trang (paging)
  final List<MediaInfoDTO> items = [];
  int page = 1;
  bool hasMore = true;
  static const int size = 24; // Số item mỗi trang

  // Các bộ lọc hiện tại
  MediaTypeFilter type = MediaTypeFilter.all;
  int? movieId;
  String? q;

  /// Tải lại danh sách từ đầu (khi đổi bộ lọc hoặc kéo để refresh).
  Future<void> refresh({MediaTypeFilter? type, int? movieId, String? query}) async {
    // Cập nhật các bộ lọc nếu được cung cấp
    if (type != null) this.type = type;
    this.movieId = movieId ?? this.movieId;
    this.q = query ?? this.q;

    // Reset lại trạng thái phân trang
    page = 1;
    hasMore = true;
    items.clear();

    // Tải trang dữ liệu đầu tiên
    await fetchMore();
  }

  /// Tải thêm dữ liệu cho trang tiếp theo.
  Future<void> fetchMore() async {
    if (loading || !hasMore) return;

    loading = true;
    error = null;
    // Thông báo cho UI biết để hiển thị vòng xoay loading
    // (Future.microtask để tránh lỗi setState during build)
    Future.microtask(notifyListeners);

    try {
      final data = await repo.listPaged(
        page: page,
        size: size,
        movieId: movieId,
        type: this.type.param,
        q: q,
      );
      if (data.items.isEmpty) {
        hasMore = false; // Đã hết dữ liệu
      } else {
        items.addAll(data.items);
        page++; // Tăng số trang cho lần gọi tiếp theo
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --- CÁC HÀM TIỆN ÍCH (HELPERS) ---

  /// Lấy URL chính để xem/phát file.
  /// Hàm này gọi hàm "chuyên gia" resolveUrl từ Repo.
  String urlOf(MediaInfoDTO m) => repo.resolveUrl(m);

  /// Lấy URL ảnh đại diện (poster).
  /// Ưu tiên dùng ảnh thumbnail nếu có, nếu không thì dùng URL chính.
  String posterOf(MediaInfoDTO m) {
    // Nếu có thumbnail, tạo một DTO tạm thời để resolve URL của thumbnail
    if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty) {
      // Hàm resolveUrl của repo hoạt động dựa trên fileUrl,
      // nên ta tạo một bản sao và thay fileUrl bằng thumbnailUrl.
      final tempDtoForThumbnail = MediaInfoDTO(
          id: m.id,
          fileName: m.fileName,
          fileExtension: m.fileExtension,
          fileSizeInBytes: m.fileSizeInBytes,
          fileDescription: m.fileDescription,
          fileUrl: m.thumbnailUrl // <-- Dùng URL của thumbnail ở đây
      );
      return repo.resolveUrl(tempDtoForThumbnail);
    }
    // Nếu không có thumbnail, dùng URL của file chính
    return repo.resolveUrl(m);
  }

  /// Kiểm tra xem file có phải là video không.
  bool isVideo(MediaInfoDTO m) {
    final e = (m.fileExtension).toLowerCase();
    return e == '.mp4' || e == '.mov' || e == '.m4v' || e == '.webm';
  }

  /// Lấy tên để hiển thị cho media (ưu tiên mô tả, sau đó đến tên file).
  String displayName(MediaInfoDTO m) =>
      (m.fileDescription?.isNotEmpty ?? false) ? m.fileDescription! : m.fileName;

  /// Đặt lại bộ lọc theo loại media và tải lại danh sách.
  void setType(MediaTypeFilter t) {
    if (type == t) return;
    refresh(type: t);
  }

  /// Đặt lại bộ lọc theo phim và tải lại danh sách.
  void setMovie(int? id) {
    if (movieId == id) return;
    refresh(movieId: id);
  }
}