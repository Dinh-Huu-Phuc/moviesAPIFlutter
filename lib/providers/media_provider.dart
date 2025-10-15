import 'package:flutter/foundation.dart';
import '../repos/media_repo.dart';
import '../models/media_dto.dart';

class MediaProvider extends ChangeNotifier {
  final MediaRepo repo;
  MediaProvider(this.repo);

  bool loading = false;
  String? error;
  List<MediaInfoDTO> items = [];

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      items = await repo.list();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --- Helpers ---

  String _normalizeBase(String url) {
    return url
        .replaceFirst('https://localhost:7138', 'http://10.0.2.2:5099')
        .replaceFirst('http://localhost:5099', 'http://10.0.2.2:5099');
  }

  String _ensureExt(String url, String ext) {
    if (ext.isEmpty) return url;
    final e = ext.startsWith('.') ? ext : '.$ext';
    return url.toLowerCase().endsWith(e.toLowerCase()) ? url : (url + e);
  }

  /// Tạo URL xem/phát file.
  String urlOf(MediaInfoDTO m) {
    final rawExt = (m.fileExtension).trim();
    final ext = rawExt.isEmpty
        ? ''
        : (rawExt.startsWith('.') ? rawExt : '.${rawExt}');

    if ((m.fileUrl ?? '').isNotEmpty) {
      var url = _normalizeBase(m.fileUrl!);
      url = _ensureExt(url, ext);
      return url;
    }

    final nameWithExt = (m.fileName).endsWith(ext)
        ? (m.fileName)
        : '${m.fileName}$ext';

    return 'http://10.0.2.2:5099/uploads/$nameWithExt';
  }

  bool isVideo(MediaInfoDTO m) {
    final e = (m.fileExtension).toLowerCase();
    return e == '.mp4' || e == '.mov' || e == '.m4v' || e == '.webm';
  }

  /// Lấy tên hiển thị cho media: ưu tiên mô tả, fallback về tên file.
  String displayName(MediaInfoDTO m) =>
      (m.fileDescription?.isNotEmpty ?? false) ? m.fileDescription! : m.fileName;

  // ✅ SỬA LẠI HÀM NÀY
  /// Lấy URL ảnh đại diện: ưu tiên thumbnail, fallback về URL file chính.
  String posterOf(MediaInfoDTO m) => m.thumbnailUrl ?? urlOf(m);
}