import '../services/movies_api.dart';
import '../models/media_dto.dart';

// ✅ Tách hằng số host ra để dễ quản lý
const String _hostHttp = 'http://10.0.2.2:5099';

String resolveUrl(MediaInfoDTO m) {
  // API đã trả fileUrl đúng -> dùng luôn
  var raw = (m.fileUrl?.isNotEmpty ?? false)
      ? m.fileUrl!
      : '$_hostHttp/uploads/${m.fileName}'; // fallback theo fileName

  // Chuẩn hoá host/path cũ (nếu còn record cũ trong DB)
  raw = raw
      .replaceAll('https://localhost:7138', _hostHttp)
      .replaceAll('http://localhost:7138', _hostHttp)
      .replaceAll('http://localhost:5099', _hostHttp)
      .replaceAll('/Images/', '/uploads/');

  // encode path segments
  final u = Uri.parse(raw);
  final encoded =
      '${u.scheme}://${u.authority}/'
      '${u.pathSegments.map(Uri.encodeComponent).join('/')}';
  return encoded;
}

class MediaRepo {
  final MoviesApi api;
  final String baseUrl; // 'http://10.0.2.2:5099'
  MediaRepo(this.api, {required this.baseUrl});

  Future<List<MediaInfoDTO>> list() => api.getAllMedia();

  // ✅ THAY THẾ TOÀN BỘ HÀM NÀY BẰNG LOGIC MỚI
  String resolveUrl(MediaInfoDTO m) {
    // 1) Ưu tiên API đã trả fileUrl
    var raw = (m.fileUrl?.isNotEmpty ?? false) ? m.fileUrl! : '';

    // 2) Fallback: tự dựng URL từ fileName nếu fileUrl trống
    if (raw.isEmpty && (m.fileName.isNotEmpty)) {
      raw = '$_hostHttp/uploads/${m.fileName}';
    }

    // 3) Chuẩn hoá các URL cũ/trái chuẩn để tương thích ngược
    // - Các biến thể của localhost -> 10.0.2.2:5099
    // - Đường dẫn /Images/ -> /uploads/
    raw = raw
        .replaceAll('https://localhost:7138', _hostHttp)
        .replaceAll('http://localhost:7138', _hostHttp)
        .replaceAll('http://localhost:5099', _hostHttp)
        .replaceAll('/Images/', '/uploads/');

    // 4) Encode URL để xử lý các ký tự đặc biệt (ví dụ: khoảng trắng trong tên file)
    try {
      // Uri.parse và toString() sẽ tự động xử lý việc encoding một cách chính xác.
      return Uri.parse(raw).toString();
    } catch (_) {
      // Fallback nếu URL quá dị dạng và không thể parse, trả về chuỗi đã chuẩn hóa.
      return raw;
    }
  }
}
